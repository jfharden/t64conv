require "digest/md5"
require "stringio"
require "tmpdir"

RSpec.shared_examples "errors when passed invalid arguments" do
  describe ".new" do
    context "when the source path doesn't exist" do
      let(:sourcepath) { _fixture_filepath("foo", "bar") }

      it "raises ArgumentError" do
        expect { handler }.to raise_error(ArgumentError, /Source filepath #{sourcepath} does not exist$/)
      end
    end

    context "when the output_dir doesn't exist" do
      let(:sourcepath) { _fixture_filepath("GAME10.T64") }
      let(:output_dir) { _fixture_filepath("foo", "bar") }

      it "raises ArgumentError" do
        expect { handler }.to raise_error(ArgumentError, /Output directory #{output_dir} does not exist$/)
      end
    end
  end
end

RSpec.shared_examples "base_flat_file" do
  subject(:handler) { described_class.new(sourcepath, tape_conv, output_dir, dryrun) }
  let(:tape_conv) { double }
  let(:output_dir) { Dir.mktmpdir("t64conv-tests-base-flat-file-handler-") }
  let(:dryrun) { false }
  let(:output_stream) { StringIO.new }

  around(:example) do |example|
    original_stdout = $stdout.clone

    $stdout = output_stream

    example.call

    $stdout = original_stdout
  end

  after(:example) { FileUtils.rm_rf(output_dir) }

  it_behaves_like "errors when passed invalid arguments"

  describe "#handle" do
    let(:sourcepath) { _fixture_filepath("game11.t64") }

    it "makes the flename uppercase" do
      handler.handle
      expect(File).to exist(_expected_destination_file("G", "GAME11", "GAME11.T64"))
      expect(File).not_to exist(_expected_destination_file("g"))
      expect(File).not_to exist(_expected_destination_file("G", "game11"))
      expect(File).not_to exist(_expected_destination_file("G", "GAME11", "game11.t64"))
    end

    it "copies the correct file" do
      handler.handle
      expect_source_and_destination_are_identical(
        sourcepath,
        _expected_destination_file("G", "GAME11", "GAME11.T64")
      )
    end

    context "when there is a version.nfo in the source directory" do
      let(:sourcepath) { _fixture_filepath("subdir4", "GAME14.T64") }

      context "and the source file is lowercase" do
        it "copies in the version.nfo uppercased" do
          handler.handle
          expect(File).to exist(_expected_destination_file("G", "GAME14", "VERSION.NFO"))
        end

        it "copies the correct version.nfo" do
          handler.handle
          expect_source_and_destination_are_identical(
            _fixture_filepath("subdir4", "version.nfo"),
            _expected_destination_file("G", "GAME14", "VERSION.NFO")
          )
        end
      end

      context "and the source file is uppercase" do
        let(:sourcepath) { _fixture_filepath("z-game1", "GAME1.T64") }

        it "copies in the VERSION.NFO" do
          handler.handle
          expect(File).to exist(_expected_destination_file("G", "GAME1", "VERSION.NFO"))
        end

        it "copies the correct VERSION.NFO" do
          handler.handle
          expect_source_and_destination_are_identical(
            _fixture_filepath("z-game1", "VERSION.NFO"),
            _expected_destination_file("G", "GAME1", "VERSION.NFO")
          )
        end
      end
    end

    context "with a file in a directory without a version at the end" do
      let(:sourcepath) { _fixture_filepath("game2 (1)", "GAME2.T64") }

      it "copies the file into the output_directory/alphabetical/game/version subdir" do
        handler.handle
        expect(File).to exist(_expected_destination_file("G", "GAME2", "1", "GAME2.T64"))
        expect(File).not_to exist(_expected_destination_file("G", "GAME2", "GAME2.T64"))
      end
    end

    context "with dryrun specified" do
      let(:sourcepath) { _fixture_filepath("game11.t64") }
      let(:dryrun) { true }

      it "doesn't copy the file to the output directory" do
        handler.handle
        expect(File).not_to exist(_expected_destination_file("G", "GAME11", "GAME11.T64"))
      end

      context "capturing stdout" do
        let(:output_stream) { $stdout }

        it "prints to stdout the path being copied from and to" do
          destpath = _expected_destination_file("G", "GAME11", "GAME11.T64")
          expect { handler.handle }.to output(/Copying #{File.expand_path(sourcepath)} -> #{destpath}/).to_stdout
        end
      end
    end
  end
end

def _expected_destination_file(*pathparts)
  File.expand_path(File.join(output_dir, *pathparts))
end

def _fixture_filepath(*path_parts)
  File.join("spec", "fixtures", "example_structure", *path_parts)
end
