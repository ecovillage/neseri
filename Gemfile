source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.2'

# Framework
gem 'rails', '~> 8.0'
gem 'puma', '~> 6.4'
gem 'pg'
gem 'bootsnap', require: false

# Assets / views
gem 'bulma-rails', '~> 0.9.4'
gem 'bulma_form_builder', git: 'https://github.com/meismann/bulma_form_builder.git'
gem 'cocoon'
gem 'font-awesome-sass', '~> 6.5'
gem 'haml'
gem 'haml-rails'
gem 'jbuilder', '~> 2.11'
gem 'jquery-rails'
gem 'sass-rails', '~> 6.0'
gem 'sprockets-rails'
gem 'turbolinks', '~> 5'

# I18n
gem 'rails-i18n', '~> 8.0'

# Auth
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable', '~> 2.0'
gem 'pretender'

# Misc
gem 'action_policy'
gem 'actionnav'
gem 'ahoy_email'
gem 'clowne'
gem 'image_processing', '~> 1.12'
gem 'pagy', '~> 8.0'
gem 'rest-client'

# Used to check that an email address' domain has a real, IANA-registered
# top-level domain (includes internationalized/IDN TLDs). No network access
# required, the suffix list ships with the gem.
gem 'public_suffix'

group :development, :test do
  gem 'byebug', platforms: [:mri, :windows]
  gem 'sqlite3', '~> 2.0'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  # minitest 6 split Minitest::Mock out into its own gem; test/services/booking_export_test.rb needs it.
  gem 'minitest-mock'
  # Test coverage report, see test/test_helper.rb for setup, and the "Test
  # coverage" section of README.md for how to view the report it produces.
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: [:windows, :jruby]
