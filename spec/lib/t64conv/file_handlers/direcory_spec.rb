require_relative "../../../../lib/t64conv/file_handlers/disk_file"
require_relative "../../../../lib/t64conv/file_handlers/tape_file"
require_relative "../../../../lib/t64conv/file_handlers/zip_file"
require_relative "../../../../lib/t64conv/file_handlers/directory_traverser"

RSpec.describe T64conv::FileHandlers::DirectoryTraverser do
  subject(:handler) { described_class.new(directory, tape_conv, dryrun) }
  let(:tape_conv) { double }
  let(:dryrun) { double }
  let(:tape_file_handler) { double }
  let(:disk_file_handler) { double }
  let(:zip_file_handler) { double }

  describe "#discover" do
    context "in a directory with a tape file" do
      let(:directory) { File.join(_fixture_file_path, "a-game2 (2)") }

      it do
        expect_tape_file("GAME2.T64")
        dont_expect_diskfile
        dont_expect_zipfile
        dont_expect_directory
        subject.discover
      end
    end

    context "in a directory with a disk file" do
      let(:directory) { File.join(_fixture_file_path, "subdir", "sub-subdir", "game4") }

      it do
        expect_disk_file("GAME4.D64")
        dont_expect_tapefile
        dont_expect_zipfile
        dont_expect_directory
        subject.discover
      end
    end

    context "in a directory with a zip file" do
      let(:directory) { File.join(_fixture_file_path, "subdir2") }

      it do
        expect_zip_file("game7.zip")
        expect_zip_file("game8.zip")
        dont_expect_tapefile
        dont_expect_diskfile
        dont_expect_directory
        subject.discover
      end
    end
  end

  def dont_expect_tapefile
    expect(T64conv::FileHandlers::TapeFileHandler).not_to receive(:new)
    expect_any_instance_of(T64conv::FileHandlers::TapeFileHandler).not_to receive(:handle)
  end

  def dont_expect_zipfile
    expect(T64conv::FileHandlers::ZipFileHandler).not_to receive(:new)
    expect_any_instance_of(T64conv::FileHandlers::ZipFileHandler).not_to receive(:handle)
  end

  def dont_expect_diskfile
    expect(T64conv::FileHandlers::DiskFileHandler).not_to receive(:new)
    expect_any_instance_of(T64conv::FileHandlers::DiskFileHandler).not_to receive(:handle)
  end

  def dont_expect_directory
    expect(described_class).to receive(:new).exactly(1).times.and_call_original
    expect_any_instance_of(described_class).to receive(:discover).exactly(1).times.and_call_original
  end

  def expect_tape_file(filename)
    expect(T64conv::FileHandlers::TapeFileHandler).to receive(:new).with(
      _path_to_file(filename),
      tape_conv,
      dryrun
    ).and_return(tape_file_handler)

    expect(tape_file_handler).to receive(:handle).with(no_args)
  end

  def expect_disk_file(filename)
    expect(T64conv::FileHandlers::DiskFileHandler).to receive(:new).with(
      _path_to_file(filename),
      tape_conv,
      dryrun
    ).and_return(disk_file_handler)

    expect(disk_file_handler).to receive(:handle).with(no_args)
  end

  def expect_zip_file(filename)
    expect(T64conv::FileHandlers::ZipFileHandler).to receive(:new).with(
      _path_to_file(filename),
      tape_conv,
      dryrun
    ).and_return(zip_file_handler)

    expect(zip_file_handler).to receive(:handle).with(no_args)
  end

  def _path_to_file(filename)
    File.join(directory, filename)
  end

  def _fixture_file_path
    File.join("spec", "fixtures", "example_structure")
  end
end
