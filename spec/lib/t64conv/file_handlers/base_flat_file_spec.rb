require_relative "../../../../lib/t64conv/file_handlers/base_flat_file"

require_relative "./shared_examples/base_flat_file"

RSpec.describe T64conv::FileHandlers::BaseFlatFileHandler do
  it_behaves_like "base_flat_file", test_convert: true
end
