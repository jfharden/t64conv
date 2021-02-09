require "tmpdir"

require_relative "../../../../lib/t64conv/file_handlers/disk_file"
require_relative "../../../../lib/t64conv/file_handlers/tape_file"
require_relative "../../../../lib/t64conv/file_handlers/zip_file"
require_relative "../../../../lib/t64conv/file_handlers/directory_traverser"

RSpec.describe T64conv::FileHandlers::DirectoryTraverser do
  subject(:handler) { described_class.new(directory, output_dir, dryrun) }
  let(:output_dir) { Dir.mktmpdir("t64conv-tests-directory-traverser-") }
  let(:dryrun) { false }
  let(:tape_file_handler) { double }
  let(:disk_file_handler) { double }
  let(:zip_file_handler) { double }
  let(:sub_dir_traverser) { double }

  after(:example) { FileUtils.rm_rf(output_dir) }

  describe ".new" do
    context "with a passed in directory which is not a directory" do
      let(:directory) { File.join(_absolute_start_directory(""), "GAME10.T64") }

      it "Should raise ArgumentError" do
        expect { handler }.to raise_error(ArgumentError, /GAME10\.T64 is not a directory$/)
      end
    end

    context "with a passed in ouput_dir which is not a directory" do
      subject(:handler) do
        filepath = File.join(_absolute_start_directory("", "GAME11.t64"))
        described_class.new(directory, filepath, dryrun)
      end
      let(:directory) { _absolute_start_directory }

      context "with dryrun enabled" do
        let(:dryrun) { true }

        it "should not raise an exception" do
          expect { handler }.not_to raise_error
        end
      end

      it "Should raise ArgumentError" do
        expect { handler }.to raise_error(ArgumentError, /output directory .*GAME11\.t64 is not a directory$/)
      end
    end
  end

  describe "#discover" do
    context "in a directory with a tape file" do
      context "with a relative path to the directory" do
        let(:directory) { _relative_start_directory("a-game2 (2)") }

        it "finds only GAME2.T64" do
          expect_tape_file("GAME2.T64")
          dont_expect_diskfile
          dont_expect_zipfile
          dont_expect_directory

          subject.discover
        end
      end

      context "with an absolute path to the directory" do
        let(:directory) { _absolute_start_directory("a-game2 (2)") }

        it "finds only GAME2.T64" do
          expect_tape_file("GAME2.T64")
          dont_expect_diskfile
          dont_expect_zipfile
          dont_expect_directory

          subject.discover
        end
      end
    end

    context "in a directory with a disk file" do
      let(:directory) { _absolute_start_directory("subdir", "sub-subdir", "game4") }

      it "finds only GAME4.D64" do
        expect_disk_file("GAME4.D64")
        dont_expect_tapefile
        dont_expect_zipfile
        dont_expect_directory

        subject.discover
      end
    end

    context "in a directory with a zip file" do
      let(:directory) { _absolute_start_directory("subdir2") }

      it "finds game7.zip and game8.zip" do
        expect_zip_file("game7.zip")
        expect_zip_file("game8.zip")
        dont_expect_tapefile
        dont_expect_diskfile
        dont_expect_directory

        subject.discover
      end
    end

    context "in a directory with only another directory" do
      let(:directory) { _absolute_start_directory("subdir3") }

      it "finds the subdir3 directory" do
        setup_directory_expect
        expect_directory("sub-subdir2")
        dont_expect_tapefile
        dont_expect_diskfile
        dont_expect_zipfile

        subject.discover
      end
    end

    context "in a directory with mixed files" do
      let(:directory) { _absolute_start_directory }

      it "finds all the directories, T64, D64, and Zip files" do
        setup_directory_expect
        expect_directory("a-game2 (2)")
        expect_tape_file("GAME10.T64")
        expect_tape_file("game11.t64")
        expect_disk_file("GAME12.D64")
        expect_disk_file("game13.d64")
        expect_directory("game2 (1)")
        expect_zip_file("GAME98.ZIP")
        expect_zip_file("game99.zip")
        expect_directory("subdir")
        expect_directory("subdir2")
        expect_directory("subdir3")
        expect_directory("subdir4")
        expect_directory("z-game1")

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

  def setup_directory_expect
    expect(described_class).to receive(:new).with(directory, output_dir, dryrun).and_call_original
  end

  def expect_directory(dirname)
    expected_directory = _absolute_path_to_file(dirname)
    expect(described_class).to receive(:new)
      .with(expected_directory, output_dir, dryrun)
      .and_return(sub_dir_traverser)
    expect(sub_dir_traverser).to receive(:discover).with(no_args)
  end

  def expect_tape_file(filename)
    expect(T64conv::FileHandlers::TapeFileHandler).to receive(:new).with(
      _absolute_path_to_file(filename),
      output_dir,
      dryrun
    ).and_return(tape_file_handler)

    expect(tape_file_handler).to receive(:handle).with(no_args)
  end

  def expect_disk_file(filename)
    expect(T64conv::FileHandlers::DiskFileHandler).to receive(:new).with(
      _absolute_path_to_file(filename),
      output_dir,
      dryrun
    ).and_return(disk_file_handler)

    expect(disk_file_handler).to receive(:handle).with(no_args)
  end

  def expect_zip_file(filename)
    expect(T64conv::FileHandlers::ZipFileHandler).to receive(:new).with(
      _absolute_path_to_file(filename),
      output_dir,
      dryrun
    ).and_return(zip_file_handler)

    expect(zip_file_handler).to receive(:handle).with(no_args)
  end

  def _absolute_path_to_file(filename)
    File.expand_path(_relative_path_to_file(filename))
  end

  def _relative_path_to_file(filename)
    File.join(directory, filename)
  end

  def _absolute_start_directory(*dirs)
    File.expand_path(_relative_start_directory(*dirs))
  end

  def _relative_start_directory(*dirs)
    File.join("spec", "fixtures", "example_structure", *dirs)
  end
end
