# neseri - workshop proposal system

A workshop proposal system for the [ecovillage Sieben Linden](https://siebenlinden.org) (but probably broad enough to be used somewhere else).

Full i18n support; German and English locales are maintained (German is the default).

The name comes from `new seminar registration system`.

The code is published under the [AGPLv3+](LICENSE.txt) and Copyright 2019-2023 Felix Wolfsteller.

## Incomplete list of features (work flows)

  * users can self-register (with email-confirmation)
  * users can create and edit seminar (workshop, event) proposals
  * users can add other instructors to seminars (via email-address, automatically sends an invitation mail)
  * instructors then become users and can create seminars (they are normal users) and edit seminars where they are registered as instructors
  * administrators can create rooms and seminar-types (which then are displayed as select boxes in the seminar form)
  * administrators can create admin-copies and lock the seminars created by users to separately work on a copy while seeing the original values the user(s) entered
  * administrators can map instructors to their legacy-system counterpart and then "publish" an admin-copy of a seminar into the legacy system (a CouchDB-backed system, pushed to via `Legacy::Export`/`Legacy::PersonExport`, see `app/lib/legacy/`)

## Configuration

See the `Deployment` section below for the ENV variables needed to get mail and the legacy-system integration working.

### Database Setup

```bash
rails db:schema:load
```

Optionally,

```bash
rails db:seed
```
which populates the db with a `user@neseri.tu`/`admin@neseri.tu` pair of dummy users and some seminar kinds.

## Development

It uses a pretty standard Ruby on Rails stack. Ruby is installed via
[mise](https://mise.jdx.dev), pinned in `mise.toml` - production deploys
(see `ansible/`) install Ruby via mise too, reading that same file straight
out of the git checkout, so there's a single place to bump the version.

```bash
curl https://mise.run | sh   # if you don't have mise yet
mise install                 # installs the Ruby version pinned in mise.toml
bundle install
docker compose up -d         # local Postgres, see docker-compose.yml
bin/rails db:setup
bin/rails s
```

`development`/`test` use Postgres (`config/database.yml`, defaulting to the
`docker-compose.yml` container at `127.0.0.1:5432`) - the same database
engine as production, just running locally instead of on the deploy target.

You can use mail_catcher; start it; visit http://localhost:1080 in browser, mailer settings in `config/environments/development.rb` are already properly set up.

### Tests

The smallish test-suite is written using MiniTest, make a test run with `rails t`.
System-tests have to be run manually with `rails t test/system` (they are not run by default) and use the selenium chrom(ium)-driver.

#### Test coverage

Every test run measures coverage via [SimpleCov](https://github.com/simplecov-ruby/simplecov) and writes an HTML
report to `coverage/index.html` (gitignored, regenerated on each run). Open it in a browser, e.g.:

```
xdg-open coverage/index.html   # Linux
open coverage/index.html       # macOS
```

It breaks coverage down by group (Models, Controllers, Helpers, ...) and, per file, highlights exactly which lines
were and weren't hit. Since unit/integration tests (`rails t`) and system tests (`rails t test/system`) are separate
runs, run both before checking the report - SimpleCov merges consecutive runs (within 10 minutes of each other)
into one combined result instead of overwriting it, so the report reflects the whole suite. Set `COVERAGE=0` to skip
instrumentation (slightly faster, e.g. for a quick single-test iteration): `COVERAGE=0 rails t test/models/seminar_test.rb`.

## Deployment

Production runs behind Hostsharing Caddy / pfsense on a Proxmox container,
deployed and managed entirely via Ansible - see [`ansible/README.md`](ansible/README.md)
for the full architecture, one-time setup and rollback story. In short:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/deploy-app.yml    # 1st: deploys the app
ansible-playbook playbooks/caddy-edge.yml    # 2nd: wires up the public edge
```

The app itself is deployed Capistrano-style (one checkout per release under
`releases/`, shared `bundle`/`storage`/config, `current` symlink flipped
only once `mise install` / `bundle install` / `assets:precompile` /
`rails db:prepare` all succeeded), running under `systemd` (`neseri-puma`)
on Puma, with Postgres (native, localhost-only) as the production database.
Ruby is installed by `mise`, reading the same `mise.toml` used locally, so
there is a single place to bump the Ruby version.

The app is configured entirely via environment variables, rendered into
`shared/app.env` by Ansible from `inventory/group_vars/proxmox_container/{vars,vault}.yml`:

    RAILS_ENV=production
    RAILS_SERVE_STATIC_FILES=true
    RAILS_MAX_THREADS=5
    WEB_CONCURRENCY=2
    DATABASE_URL=postgresql://user:password@127.0.0.1:5432/neseri_production
    HOST=yourhost.example              # to generate absolute URLs in routes
    MAILER_HOST=yourhost.example       # to generate absolute URLs in mails
    SENDER_EMAIL="Neseri Your Community <registration@yourhost.example>"
    SMTP_SERVER=yourhost.example
    SMTP_DOMAIN=yourhost.example
    SMTP_PORT=587
    SMTP_PWD=your-smtp-password
    SMTP_USER=your-smtp-user

The Rails master key (`config/master.key`) is deployed separately and does
not go through the environment.

## Contributing

Contributions are welcome. Please respect the [Code of Conduct](CODE_OF_CONDUCT.md) and drop me a line or create a github issue.

neseri is released under the [AGPLv3 or any later version](LICENSE.txt) which is [included in the source code](agpl-3.0.md)

### Gotchas and architectural documentation

### Inherit from NeseriController

For new controllers, inherit from `NeseriController` to include verification and proper redirection for unauthorized (in the sense of `ActionPolicy`) controller actions. We are not using the `ApplicationController` to let devise (the authentication system) behave well without overriding the respective `DeviseController`s to add `skip_authorization_verifiction`. A similar argument can be done for the "static" pages from `PageController`.

### Tricks and nice additions from other gems

  - multiple flashs via [a flash helper](app/helpers/flash_helper.rb).
  - visit [/flashs](/flashs) to see how the rendered flashs look like
  - [https://ddnexus.github.io/pagy/](pagy) for pagination, despite the loud self-praise
  - authentication via [devise](https://github.com/plataformatec/devise) (invitations via [devise_invitable](https://github.com/scambra/devise_invitable))
  - authorization via [action_policy](https://actionpolicy.evilmartians.io/)
  - some navigation via the yet underdeveloped but cool [actionnav](https://github.com/adamcooke/actionnav)
  - nested forms magic with [cocoon](https://github.com/nathanvda/cocoon)
  - mail archive via [ahoy_mail](https://github.com/ankane/ahoy_email) - but no tracking
  - model/resource cloning with [clowne](https://github.com/palkan/clowne) (see `app/cloners/`)
  - [bulma](http://bulma.io/) as a decent css framework with a ill-conceived but handy [Form Builder](https://github.com/meismann/bulma_form_builder) for some visual consistency.
  - [FontAwesome Icons](http://fontawesome.com/)

And of course all the awesomeness by the rest of the ecosystem. Obviously, see the [Gemfile](Gemfile) for some direct dependencies.

### I18n

A config for [i18n-tasks](https://github.com/glebm/i18n-tasks) is prepared under `config/i18n-tasks.yml`

### Dealing with legacy data

Some rake-tasks are provided to deal with specific legacy data of a prior application.
As the data was messy, such is the code.

In a gist:
  * `rails neseri:create_legacy_json > data.json` creates a JSON file, that
  * `rails neseri:import_legacy_json` will consume (and create respective users, seminars, etc.)

#### Publishing into the legacy system

Once instructors are mapped to their legacy-system counterpart (`Publication::UserMapping`, done from an admin-copy's publication screen), an admin-copy of a seminar can be "published": this pushes JSON documents for the seminar and its instructors into the legacy system via simple HTTP PUTs (the legacy system is backed by a CouchDB). See `app/lib/legacy/export.rb` and `app/lib/legacy/person_export.rb`. The legacy system's URL and web-URL are configured at runtime under `/admin/settings`, stored as `Setting` records (`legacy_db_uri`, `legacy_web_url`).
