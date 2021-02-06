require_relative "../../../../lib/t64conv/file_handlers/disk_file"

require_relative "./shared_examples/base_flat_file"

RSpec.describe T64conv::FileHandlers::DiskFileHandler do
  it_behaves_like "base_flat_file"
end
