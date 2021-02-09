require_relative "../../../../lib/t64conv/file_handlers/tape_file"

require_relative "./shared_examples/base_flat_file"

RSpec.describe T64conv::FileHandlers::TapeFileHandler do
  subject(:handler) { described_class.new(sourcepath, output_dir, dryrun) }
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

    let(:open3_capture_mock) { double }

    context "when the conversion succeeds" do
      let(:status_mock) { double success?: true }

      it "runs the conversion with c1541 and makes the filename uppercase" do
        expected_destination = _expected_destination_file("G", "GAME11", "GAME11.D64")

        expect(Open3).to receive(:capture2e).with(
          "c1541", "-format", "GAME11,00", "d64", expected_destination, "8", "-tape", File.expand_path(sourcepath)
        ).and_return(["", status_mock])

        handler.handle
      end

      context "when the directory has a single quote in" do
        let(:sourcepath) { _fixture_filepath("someone's game15", "game15.t64") }

        it "has a well quoted sourcepath" do
          expected_destination = _expected_destination_file("G", "GAME15", "GAME15.D64")

          expected_source = File.join(
            File.expand_path(_fixture_filepath),
            "someone's game15",
            "game15.t64"
          )

          expect(Open3).to receive(:capture2e).with(
            "c1541", "-format", "GAME15,00", "d64", expected_destination, "8", "-tape", expected_source
          ).and_return(["", status_mock])

          handler.handle
        end
      end
    end

    context "when the conversion fails" do
      let(:status_mock) { double success?: false }
      let(:captured_stderr) { StringIO.new }

      around(:example) do |example|
        original_stderr = $stderr.clone

        $stderr = captured_stderr

        example.call

        $stdout = original_stderr
      end

      it "outputs the error as a warning" do
        expected_destination = _expected_destination_file("G", "GAME11", "GAME11.D64")
        expected_source = File.expand_path(sourcepath)
        fail_output = "TEST FAIL OUT"

        expected_command = ["c1541", "-format", "GAME11,00", "d64", expected_destination, "8", "-tape", expected_source]

        expect(Open3).to receive(:capture2e).with(*expected_command).and_return([fail_output, status_mock])

        handler.handle

        expect(captured_stderr.string).to eq(
          "Conversion of #{File.expand_path(sourcepath)} -> #{expected_destination} failed.\n" \
          "Command was #{expected_command}. Output from c1541 follows:\n" \
          "----\n#{fail_output}----\n\n"
        )
      end
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
        expect(File).to exist(_expected_destination_file("G", "GAME2", "1", "GAME2.D64"))
        expect(File).not_to exist(_expected_destination_file("G", "GAME2", "GAME2.D64"))
      end
    end

    context "with dryrun specified" do
      let(:sourcepath) { _fixture_filepath("game11.t64") }
      let(:dryrun) { true }

      it "doesn't copy the file to the output directory" do
        handler.handle
        expect(File).not_to exist(_expected_destination_file("G", "GAME11", "GAME11.D64"))
      end

      context "capturing stdout" do
        let(:output_stream) { $stdout }

        it "prints to stdout the path being copied from and to" do
          destpath = _expected_destination_file("G", "GAME11", "GAME11.D64")
          full_sourcepath = File.expand_path(sourcepath)

          expect { handler.handle }.to output(/Converting #{full_sourcepath} -> #{destpath}/).to_stdout
        end
      end
    end
  end
end
