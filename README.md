# neseri - workshop proposal system

[![Build Status](https://travis-ci.org/ecovillage/neseri.svg?branch=master)](https://travis-ci.org/ecovillage/neseri)

A workshop proposal system for the [ecovillage Sieben Linden](https://siebenlinden.org) (but probably broad enough to be used somewhere else).

Full i18n support, but currently only a proper German locale is available.

The name comes from `new seminar registration system`.

The code is published under the [AGPLv3+](LICENSE.txt) and Copyright 2019 Felix Wolfsteller.

## Incomplete list of features (work flows)

  * users can self-register (with email-confirmation)
  * users can create and edit seminar (workshop, event) proposols
  * users can add other referees to seminars (via email-address, automatically sends an invitation mail)
  * referees then become users and can create seminars (they are normal users) and edit seminars where they are registered as referees
  * administrators can create rooms and seminar-types (which then are displayed as select boxes in the seminar form)
  * administrators can create admin-copies and lock the seminars created by users to separately work on a copy while seeing the original values the user(s) entered
  * (TODO) with the proper legacy system in the backend, referees and and seminars can be "published" into the legacy system

## Configuration

See `Deployment` section for ENV variables to get mails kicking.

### Database Setup

```bash
rails db:schema:load
```

Optionally,

```bash
rails db:seed
```
which populates the db with some dummy users.

## Deployment instructions

You need a JavaScript runtime, otherwise rails will bail out (`ExecJS::RuntimeUnavailable: Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.`).
Check the link and install one of the runtimes.
If the error persists, mention a gem in the Gemfile (I go with [therubyracer](https://github.com/cowboyd/therubyracer), thus add `gem 'therubyracer'` in `Gemfile` and re-run `bundle`).

### Poor mans setup

  * have a host with installed ruby (>= 2.6.1)
  * clone the git repository (`git clone https://github.com/ecovillage/neseri`)
  * `cd neseri` into the directory
  * run `bundle`
  * then `RAILS_ENV=production rails db:schema:load` (or `rails db:migrate` to update)
  * `RAILS_ENV=production rails credentials:edit` (delete config/master.key and similar if already present)
  * export `SERVE_STATIC_FILES=true` environment variable
  * set mailhost and other ENVs (see below)
  * `rails assets:precompile`
  * fire up `rails s -p 4000 -b 0.0.0.0` to run the application on **port 4000** on all (even public) IPs of the machine.

In production, make sure to have these environment variables set (with proper values of course):

    HOST=yourhost.comm
    MAILER_HOST=yourhost.commm # to generate absolute URLs in mails
    DATABASEURL=postgres://aksdjl:aslkalksd@djief:342/aksdu
    SENDER_EMAIL="Neseri\ Your\ Community\ <registration@yourhost.commm>"
    SMTP_SERVER=yourhost.commm
    SMTP_DOMAIN=yourhost.commm
    SMTP_PORT=587
    SMTP_PWD=9098asdjlker!
    SMTP_USER=iaowur32oalks

Works fine with dokku.


## Development

`neseri` is currently developed using Ruby 2.6.1 and Rails 5.x.
It uses a pretty standard Ruby on Rails stack.

To get started, `git checkout` the code, `bundle` to install the required ruby gems, `db:setup` the database and `rails s` the server.

You can use mail_catcher; start it; visit http://localhost:1080 in browser, mailer settings in `config/environments/development.rb` are already properly set up.

### Tests

The small test-suite is written using MiniTest, make a test run with `rails t`.
System-tests have to be run manually with `rails t test/system` (they are not run by default).

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
  - authentication via [devise](https://github.com/plataformatec/devise)
  - authorization via [action_policy](https://actionpolicy.evilmartians.io/)
  - some navigation via the yet underdeveloped but cool [actionnav](https://github.com/adamcooke/actionnav)
  - nested forms magic with [cocoon](https://github.com/nathanvda/cocoon)
  - mail archive via [ahoy_mail](https://github.com/ankane/ahoy_email) - but no tracking
  - model/resource cloning with [clowne](https://github.com/palkan/clowne)
  - [bulma](http://bulma.io/) as a decent css framework with a ill-conceived but handy [Form Builder](https://github.com/fwolfst/bulma_form_builder) for some visual consistency.
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

#### Exporting data

TBD

#### Exporting directly into legacy data

TBD
