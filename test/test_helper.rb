# Coverage tracking has to start before any application code is loaded
# (below), and is opt-out via COVERAGE=0 since it slows the suite down a
# bit. See the "Test coverage" section in README.md for how to view the
# HTML report this produces (coverage/index.html).
if ENV['COVERAGE'] != '0'
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  make_my_diffs_pretty!

  # ActionMailer::Base.deliveries is a plain array that isn't reset between
  # tests on its own, so tests that send mail (e.g. invitations) would leak
  # into whichever test runs next in the same process and asserts on it.
  setup do
    ActionMailer::Base.deliveries.clear
  end
end
