require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  # :rack_test, :selenium_chrome, or :selenium_chrome_headless.
  # :poltergeist, :webkit
end
