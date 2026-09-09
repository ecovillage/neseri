require "test_helper"

# System tests run as a separate `bin/rails test:system` process from the
# rest of the suite. Without a command name distinct from the regular run's
# ("Minitest" for both, by SimpleCov's own guesswork), the later process's
# coverage data replaces the earlier one's in coverage/.resultset.json
# instead of being merged into it, so combined coverage reports (and
# `bin/rails test:all`, which runs both in turn) would silently only ever
# reflect whichever suite ran last.
SimpleCov.command_name "System Tests" if defined?(SimpleCov)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  # :rack_test, :selenium_chrome, or :selenium_chrome_headless.
  # :poltergeist, :webkit
end
