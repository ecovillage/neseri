# neseritu - workshop proposal system

A workshop proposal system for the ecovillage Sieben Linden.

This README would normally document whatever steps are necessary to get the
application up and running.

The name comes from `new seminar registration system 2`.

## Development

`neseritu` is currently developed using Ruby 2.6.1 and Rails 5.x.
Otherwise it uses a pretty standard Ruby on Rails stack.

### Gotchas

### Inherit from NeserituController
For new controllers, inherit from `NeserituController` to include verification and proper redirection for unauthorized (in the sense of `ActionPolicy`) controller actions. We are not using the `ApplicationController` to let devise (the authentication system) behave well without overriding the respective `DeviseController`s to add `skip_authorization_verifiction`. A similar argument can be done for the "static" pages from `PageController`.

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

* How to run the test suite

None yet.

* Services (job queues, cache servers, search engines, etc.)

None yet.

* Deployment instructions

In production (haha), make sure to have these environment variables set(with proper values of course):

    MAILER_HOST=yourhost.commm # to generate absolute URLs in mails
    DATABASEURL=postgres://aksdjl:aslkalksd@djief:342/aksdu
    #SENDER_EMAIL=registration@yourhost.commm
    SMTP_SERVER=yourhost.commm
    SMTP_DOMAIN=yourhost.commm
    SMTP_PORT=587
    SMTP_PWD=9098asdjlker!
    SMTP_USER=iaowur32oalks

Works fine with dokku.

* ...
