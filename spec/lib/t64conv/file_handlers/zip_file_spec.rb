require_relative "../../../../lib/t64conv/file_handlers/zip_file"
require_relative "../../../../lib/t64conv/file_handlers/directory_traverser"

RSpec.describe T64conv::FileHandlers::ZipFileHandler do
  let(:output_dir) { double }
  let(:dryrun) { false }
  let(:output_stream) { StringIO.new }

  tests = {
    "a T64 file" => "t64_in_subdir.zip",
    "a D64 file" => "d64_file.zip",
    "multiple_files" => "multiple_files.zip",
    "interesting files and the zip file name has a version number" => "with_version (123).zip",
    "a zip file" => "ZIP_FILE.ZIP",
  }

  around(:example) do |example|
    original_stdout = $stdout.clone

    $stdout = output_stream

    example.call

    $stdout = original_stdout
  end

  describe "#zip_interesting?" do
    it "returns false when uninteresting" do
      handler = described_class.new(_fixture_file_path("uninteresting.zip"), output_dir, dryrun)
      expect(handler.zip_interesting?).to be false
    end

    tests.each do |file_contents, filename|
      it "returns true when the zip contains #{file_contents}" do
        handler = described_class.new(_fixture_file_path(filename), output_dir, dryrun)
        expect(handler.zip_interesting?).to be true
      end
    end
  end

  let(:original_mktmpdir) { Dir.method(:mktmpdir) }

  describe "#handle" do
    let(:traverser) { double }

    tests.each do |file_contents, filename|
      it "extracts correctly #{file_contents}" do
        original_mktmpdir.call("t64conv-") do |tmpdir|
          allow(Dir).to receive(:mktmpdir).with("t64conv-") do |&block|
            block.call(tmpdir)
          end

          zip_file_path = _fixture_file_path(filename)
          handler = described_class.new(zip_file_path, output_dir, dryrun)

          extract_dir = File.join(tmpdir, File.basename(filename, ".*"))
          expect(T64conv::FileHandlers::DirectoryTraverser).to receive(:new).with(extract_dir, output_dir, dryrun) do
            expect_files_to_be_extracted_into(filename, extract_dir)
          end.and_return(traverser)

          expect(traverser).to receive(:discover).with(no_args)

          handler.handle
        end
      end
    end
  end

  def expect_files_to_be_extracted_into(zip_file, extract_dir)
    File.readlines(_manifest_file_path(zip_file)).each do |line|
      test_for, path = line.rstrip.split(" ", 2)
      safe_path = File.join(*path.split("/"))
      fullpath = File.join(extract_dir, safe_path)

      _expect_path_to_be_type(fullpath, test_for)
    end
  end

  def _expect_path_to_be_type(path, type)
    case type
    when "f"
      expect(File.file?(path)).to be true
    when "d"
      expect(File.directory?(path)).to be true
    else
      raise "Unknown file type to test for"
    end
  end

  def _manifest_file_path(zip_file)
    manifest_name = "#{File.basename(zip_file, '.*')}.manifest"
    _fixture_file_path(manifest_name)
  end

  def _fixture_file_path(filename)
    File.join("spec", "fixtures", "zip_files", filename)
  end
end
