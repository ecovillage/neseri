`neseri-backend-ca.crt` is fetched into this directory by
`playbooks/deploy-app.yml` (task "Fetch the Caddy-internal CA root
certificate"). It's gitignored on purpose - it's generated, not authored.
Run `deploy-app.yml` before `caddy-edge.yml` if it's missing.
