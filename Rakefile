# frozen_string_literal: true

require "rake/testtask"

# Unit tests: no network, no mock server.
Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.test_files = FileList["test/**/*_test.rb"].exclude("test/integration/**/*")
end

# Integration tests: need Go (they boot the spec repo's mock server) and the
# kilden-sdk-spec checkout (KILDEN_SPEC_DIR, default ../kilden-sdk-spec).
Rake::TestTask.new(:integration) do |t|
  t.libs << "test" << "lib"
  t.test_files = FileList["test/integration/**/*_test.rb"]
end

task all: %i[test integration]
task default: :test
