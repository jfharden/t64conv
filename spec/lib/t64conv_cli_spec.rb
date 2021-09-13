require "securerandom"

require_relative "../../lib/t64conv"

RSpec.describe T64conv::Cli do
  subject(:cli) { described_class.new }

  let(:captured_stdout) { StringIO.new }
  let(:captured_stderr) { StringIO.new }

  let(:args) { [] }
  let(:traverser) { double }

  before(:example) do
    allow(traverser).to receive(:discover).with(no_args)
  end

  around(:example) do |example|
    original_stdout = $stdout.clone
    original_stderr = $stderr.clone

    $stdout = captured_stdout
    $stderr = captured_stderr

    example.call

    $stderr = original_stderr
    $stdout = original_stdout
  end

  context "without any switches" do
    it "uses ./ as the source dir" do
      expect(T64conv::FileHandlers::DirectoryTraverser)
        .to receive(:new)
        .with(".", anything, anything)
        .and_return(traverser)

      expect { cli.convert(args) }.not_to raise_error
    end

    it "user ./C64DISKS as the output dir" do
      expect(T64conv::FileHandlers::DirectoryTraverser)
        .to receive(:new)
        .with(anything, File.join(".", "C64DISKS"), anything)
        .and_return(traverser)

      expect { cli.convert(args) }.not_to raise_error
    end

    it "sets dryrun to false" do
      expect(T64conv::FileHandlers::DirectoryTraverser)
        .to receive(:new)
        .with(anything, anything, false)
        .and_return(traverser)

      expect { cli.convert(args) }.not_to raise_error
    end
  end

  context "when passed the version flag" do
    shared_examples "it shows the version" do
      it "prints the version message" do
        # rubocop:disable Lint/SuppressedException
        expect do
          begin
            cli.convert(args)
          rescue SystemExit
          end
        end.to output(/t64conv \d+\.\d+\.\d+ \(c\) 20[0-9]{2} Jonathan F Harden/).to_stdout
        # rubocop:enable Lint/SuppressedException
      end

      it "exits" do
        expect { cli.convert(args) }.to raise_error(SystemExit)
      end
    end

    context "with -v" do
      let(:args) { ["-v"] }

      it_behaves_like "it shows the version"
    end

    context "with --version" do
      let(:args) { ["--version"] }

      it_behaves_like "it shows the version"
    end
  end

  context "when passed the help flag" do
    shared_examples "it shows the help" do
      it "prints the help message" do
        # rubocop:disable Lint/SuppressedException
        expect do
          begin
            cli.convert(args)
          rescue SystemExit
          end
        end.to output(/t64conv recursively traverses/).to_stdout
        # rubocop:enable Lint/SuppressedException
      end

      it "exits" do
        expect { cli.convert(args) }.to raise_error(SystemExit)
      end
    end

    context "with -h" do
      let(:args) { ["-h"] }

      it_behaves_like "it shows the help"
    end

    context "with --help" do
      let(:args) { ["--help"] }

      it_behaves_like "it shows the help"
    end
  end

  context "when passed the dryrun flag" do
    shared_examples "it runs in dryrun mode" do
      it "sets dryrun to be true" do
        expect(T64conv::FileHandlers::DirectoryTraverser)
          .to receive(:new)
          .with(".", File.join(".", "C64DISKS"), true)
          .and_return(traverser)

        expect { cli.convert(args) }.not_to raise_error
      end

      it "does not make the output directory" do
        Dir.mktmpdir("t64conv-tests-cli-") do |tmpdir|
          outdir = File.join(tmpdir, SecureRandom.uuid)

          expect(T64conv::FileHandlers::DirectoryTraverser)
            .to receive(:new)
            .with(".", outdir, true)
            .and_return(traverser)

          expect { cli.convert(args + ["-o", outdir]) }.not_to raise_error

          expect(File).not_to exist(outdir)
        end
      end
    end

    context "with -d" do
      let(:args) { ["-d"] }

      it_behaves_like "it runs in dryrun mode"
    end

    context "with --dryrun" do
      let(:args) { ["--dryrun"] }

      it_behaves_like "it runs in dryrun mode"
    end
  end

  context "when passed the source-dir flag" do
    around(:example) do |example|
      Dir.mktmpdir("t64conv-tests-cli-") do |dir|
        @tmpdir = dir
        example.call
      end
    end

    shared_examples "it uses the specified source dir" do
      it "sets the source dir to be where the user specified" do
        expect(T64conv::FileHandlers::DirectoryTraverser)
          .to receive(:new)
          .with(@tmpdir, File.join(".", "C64DISKS"), false)
          .and_return(traverser)

        expect { cli.convert([flag, @tmpdir]) }.not_to raise_error
      end
    end

    context "with -s" do
      let(:flag) { "-s" }

      it_behaves_like "it uses the specified source dir"
    end

    context "with --source-dir" do
      let(:flag) { "--source-dir" }

      it_behaves_like "it uses the specified source dir"
    end
  end

  context "when passed the output-dir flag" do
    around(:example) do |example|
      Dir.mktmpdir("t64conv-tests-cli-") do |dir|
        @tmpdir = dir
        example.call
      end
    end

    shared_examples "it uses the specified output dir" do
      it "sets the output dir to be where the user specified" do
        expect(T64conv::FileHandlers::DirectoryTraverser)
          .to receive(:new)
          .with(".", @tmpdir, false)
          .and_return(traverser)

        expect { cli.convert([flag, @tmpdir]) }.not_to raise_error
      end
    end

    context "with -o" do
      let(:flag) { "-o" }

      it_behaves_like "it uses the specified output dir"
    end

    context "with --output-dir" do
      let(:flag) { "--output-dir" }

      it_behaves_like "it uses the specified output dir"
    end
  end

end
