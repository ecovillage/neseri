# neseri - workshop proposal system

A workshop proposal system for the ecovillage Sieben Linden (but probably broad enough to be used somewhere else).

Full i18n support, but currently only a proper German locale is available.

The name comes from `new seminar registration system`.

The code is published under the [AGPLv3+](LICENSE.txt) and Copyright 2019 Felix Wolfsteller.

`neseri` is currently developed using Ruby 2.6.1 and Rails 5.x.
Otherwise it uses a pretty standard Ruby on Rails stack.

### Gotchas

### Inherit from NeseriController
For new controllers, inherit from `NeseriController` to include verification and proper redirection for unauthorized (in the sense of `ActionPolicy`) controller actions. We are not using the `ApplicationController` to let devise (the authentication system) behave well without overriding the respective `DeviseController`s to add `skip_authorization_verifiction`. A similar argument can be done for the "static" pages from `PageController`.

## Configuration

See `Deployment` section for ENV variables to get mails kicking.

* Database creation

* Database initialization

```bash
rails db:schema:load
```

Optionally,

```bash
rails db:seed
```
which populates the db with some dummy users.

* Development

You can use mail_catcher; start it; visit http://localhost:1080 in browser, mailer settings in `config/environments/development.rb` is already properly set up.

* How to run the test suite

None yet.

* Services (job queues, cache servers, search engines, etc.)

None yet.

* Deployment instructions

You need a JavaScript runtime, otherwise rails will bail out (`ExecJS::RuntimeUnavailable: Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.`).
Check the link and install one of the runtimes.
If the error persists, mention a gem in the Gemfile (I go with [therubyracer](https://github.com/cowboyd/therubyracer), thus add `gem 'therubyracer'` in `Gemfile` and re-run `bundle`).


In production (haha), make sure to have these environment variables set(with proper values of course):

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

* Tricks:
  - multiple flashs via flash_helper
  - visit /flashs for design stuff

* ...

## Dealing with legacy data

Some rake-tasks are provided to deal with specific legacy data of a prior application.
As the data was messy, such is the code.

In a gist:
  * `rails neseri:create_legacy_json > data.json` creates a JSON file, that
  * `rails neseri:import_legacy_json` will consume (and create respective users, seminars, etc.)
