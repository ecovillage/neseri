# neseri deployment

Deploys neseri to production behind pfsense, with a Hostsharing Caddy as the
public edge. The app is git-cloned onto the Proxmox container,
`bundle install`ed, migrated and run under systemd, next to native Postgres
and Caddy installs.

## Architecture

```
Browser --TLS--> Hostsharing Caddy --TLS--> pfsense (212.91.243.26:443)
(vm4007.hostsharing.net,                      |  NAT
 DNS: neseri.siebenlinden.org)                v
                                    Proxmox container (192.168.1.135)
                                      caddy:443 --TLS--> 127.0.0.1:3000 (Puma, systemd)
                                                          postgres (systemd, localhost:5432)
```

Traffic is TLS end-to-end. It is **not** a single passed-through TLS session
though (that would need Caddy's `layer4` module, which isn't built into the
plain `caddy` image Hostsharing runs for this account, and rebuilding it
would risk the mailcow/mailman sites sharing that same container). Instead:

- The Hostsharing Caddy holds the **real, publicly-trusted Let's Encrypt
  certificate** for `neseri.siebenlinden.org` - it's the only place that can
  get one, since that's what DNS actually points at.
- It then opens a **second TLS connection** to pfsense's public IP, which
  NATs it through to the container's own Caddy.
- The container's Caddy can't get a public certificate for that name either
  (DNS doesn't point at pfsense), so it mints its own certificate from
  Caddy's built-in local CA (`tls internal`).
- The Hostsharing Caddy is handed that CA's root certificate and validates
  the backend leg against it (`tls_trust_pool`), so nothing is silently
  unverified (no `insecure_skip_verify` anywhere).

This is why **`playbooks/deploy-app.yml` has to run before
`playbooks/caddy-edge.yml`**: the CA root certificate the edge needs to trust
is only produced once the app has been deployed.

## On the container

`roles/neseri_app` sets up, natively via apt/systemd:

- **Ruby**, installed by `mise install` run inside each new release
  checkout, which reads the version straight from the repo's own
  `mise.toml` - the same file local dev uses, and the only place the
  version is pinned. mise uses a precompiled binary where one exists for
  the platform/version; otherwise it compiles from source (the build
  toolchain from `01-packages.yml` stays installed either way, since native
  gems compile from source via bundler regardless). A version already
  installed from an earlier release is reused, so this is only slow on the
  deploy that actually bumps `mise.toml`.
- **Postgres**, tuned down a bit (see `postgres_shared_buffers` etc. in
  `vars.yml`) and listening on `127.0.0.1` only.
- **Caddy**, from the official apt repo, same internal-CA TLS setup as
  before.
- **The app itself**, deployed Capistrano-style:
  ```
  /opt/neseri/
    releases/<timestamp>/   one full checkout per deploy
    current -> releases/... symlink to the active release
    shared/
      bundle/                installed gems, shared across releases
      storage/                Active Storage files
      config/master.key, config/database.yml   symlinked into each release
      app.env                 EnvironmentFile for the systemd unit
  ```
  Each deploy: `git clone` the pinned ref into a new `releases/` dir →
  symlink in the shared config/storage → `mise install` → `bundle install`
  (into `shared/bundle`, so only new/changed gems are actually installed) →
  `assets:precompile` → `rails db:prepare` → flip the `current` symlink →
  `systemctl restart neseri-puma`. `current` only moves once everything
  before it succeeded, so a broken deploy never touches the running app.
  The last `neseri_keep_releases` (default 5) releases are kept around -
  **rollback** = symlink `current` to an older `releases/<timestamp>` and
  `systemctl restart neseri-puma`.

**Only pushed, committed code gets deployed** - `ansible.builtin.git`
clones from GitHub at `neseri_deploy_ref` (default `master`). Unlike the old
rsync-based deploy, uncommitted local changes are never shipped; push first.

## One-time setup

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Secrets live in `inventory/group_vars/proxmox_container/vault.yml`, encrypted with
ansible-vault. The password was generated for you into `.vault_pass.txt`
(gitignored, never commit it) - move it into a password manager and delete
the file, or leave it if you're fine with `ansible-playbook` picking it up
automatically via `ansible.cfg`'s `vault_password_file`. To edit the vault:

```bash
ansible-vault edit inventory/group_vars/proxmox_container/vault.yml
```

### GitHub deploy key

The container needs read access to this repo to `git clone` it. No secret
lives in the vault for this - `deploy-app.yml` generates an ed25519 keypair
on the container itself (once; `{{ neseri_app_dir }}/.ssh/id_ed25519`,
reused by every later deploy) and clones over SSH.

The **first** run will get as far as printing the public key, then fail the
clone with "Permission denied (publickey)" - GitHub doesn't know about the
key yet:

1. Run `ansible-playbook playbooks/deploy-app.yml` once and copy the public
   key from its output (task "Show the deploy public key").
2. Add it at
   <https://github.com/ecovillage/neseri/settings/keys> → "Add deploy key" -
   paste it, leave **"Allow write access" unchecked** (read-only is all it
   needs).
3. Rerun `ansible-playbook playbooks/deploy-app.yml` - the clone succeeds
   now.

This replaces the old `vault_ghcr_username`/`vault_ghcr_token` - GHCR isn't
used anymore, so those two can be deleted from the vault.

To rotate the key: delete `{{ neseri_app_dir }}/.ssh/id_ed25519*` on the
container, remove the old deploy key from GitHub, and rerun (repeats the
bootstrap above with a fresh keypair).

## Running

```bash
cd ansible
ansible-playbook playbooks/deploy-app.yml    # 1st: deploys the app
ansible-playbook playbooks/caddy-edge.yml    # 2nd: wires up the public edge
```

Re-running either playbook is safe (idempotent); re-running `deploy-app.yml`
deploys whatever is currently on `neseri_deploy_ref` on GitHub as a new
release and restarts the app - Ruby/Postgres/Caddy installs and old releases
beyond `neseri_keep_releases` are left alone (build/prune) or updated in
place (config).

## Resource note

The container has 1GB+ RAM / 8GB disk. Postgres is tuned down
(see `vars.yml`) and Puma runs a single worker (`RAILS_MAX_THREADS: "3"`).
Compiling Ruby and native gems is one-off/incremental work (skipped once
already built/installed), not something that happens on every deploy.

## pfsense

pfsense needs one NAT rule: WAN TCP/443 -> 192.168.1.135:443. See the chat
for the exact steps; consider restricting the source of that rule to
Hostsharing's IP (`83.223.91.233`), since nothing else needs to reach that
port directly.

## Layout

```
ansible.cfg
inventory/hosts.yml                     caddy_edge (Hostsharing) / proxmox_container
inventory/group_vars/caddy_edge/        non-secret vars for the edge
inventory/group_vars/proxmox_container/ vars.yml (non-secret) + vault.yml (secrets)
playbooks/deploy-app.yml                run 1st
playbooks/caddy-edge.yml                run 2nd
roles/neseri_app/                       installs Ruby/Postgres/Caddy, deploys and runs the app on the container
roles/caddy_edge/                       adds the neseri site block to the Hostsharing Caddyfile
```
