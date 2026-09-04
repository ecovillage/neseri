# `test:all` (and friends like `test:units`) are already defined by Rails
# itself (see railties' rails/test_unit/testing.rake), but Rails leaves them
# without a `desc`, so they don't show up in `rake -T`. Attach a description
# to the existing task so it's discoverable without changing its behavior.
desc "Run all tests, including system tests"
task "test:all"
