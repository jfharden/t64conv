require "bundler/setup"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def expect_source_and_destination_are_identical(source, dest)
  source_md5 = Digest::MD5.hexdigest(File.read(source))
  dest_md5 = Digest::MD5.hexdigest(File.read(dest))

  expect(source_md5).to eq dest_md5
end
