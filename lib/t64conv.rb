require "open3"
require "optimist"

require_relative "./t64conv/version"
require_relative "./t64conv/file_handlers/directory_traverser"

module T64conv
  # Provides the CLI interface to T64conv
  class Cli
    BANNER = <<~END_OF_BANNER.freeze
      t64conv recursively traverses a directory structure looking for c64 disks (.D64) and tape (.T64) files, it also
      looks inside zip files to find them.

      It will output to a directory structure of <output_dir>/<letter>/<game_name>/<game_name>.D64 after converting T64
      files into D64 files using c1541 (which is provided with the VICE emulator). Any VERSION.NFO file found in same
      directory will also be copied to the destination.

      If the game has a version number in it's directory/zip name it will add the version number as an output directory too.

      Examples:

        <output_dir>/S/SHOWDOWN/SHOWDOWN.D64
        <output_dir>/S/SHOWDOWN/VERSION.NFO

      with a version:

        <output_dir>/S/SHOWDOWN/12341/SHOWDOWN.D64
        <output_dir>/S/SHOWDOWN/12341/VERSION.NFO

      Usage:
       t64conv [options]

      where [options] are:

    END_OF_BANNER

    def convert(args)
      opts = _parse_options(args)

      _check_c1541_installation

      _validate_source_dir(opts[:source_dir])
      _validate_and_create_output_dir(opts[:output_dir], opts)

      traverser = T64conv::FileHandlers::DirectoryTraverser.new(opts[:source_dir], opts[:output_dir], opts[:dryrun])
      traverser.discover
    end

    def _parse_options(args)
      Optimist.options(args) do
        version "t64conv #{T64conv::VERSION} (c) 2021 Jonathan F Harden"
        banner BANNER
        opt :dryrun, "Run in dryrun mode, don't perform operations, only list what would be performed.", default: false
        opt :output_dir, "Output to this directory instead of the default.", type: String, default: "./C64DISKS"
        opt :source_dir, "Where to start looking for files.", type: String, default: "./"
      end
    end

    def _validate_source_dir(dir)
      Optimist.die :source_dir, "#{dir} does not exist" unless File.exist?(dir)

      Optimist.die :source_dir, "#{dir} exists but is not a directory" unless File.directory?(dir)
    end

    def _validate_and_create_output_dir(dir, opts)
      return if File.directory?(dir)

      Optimist.die :output_dir, "#{dir} already exists and is not a directory" if File.exist?(dir)

      FileUtils.mkdir_p(dir) unless opts[:dryrun]
    end

    def _check_c1541_installation
      output, status = Open3.capture2e("c1541 -version")

      return if status.success?

      abort("Error executing c1541, error was:\n#{output}")
    rescue StandardError => e
      abort(
        "Cannot execute c1541\n" \
        "Perhaps you need to install the VICE emulator (https://vice-emu.sourceforge.io/)\n" \
        "If it is already installed make sure it is in your PATH environment\n" \
        "Error was: #{e}"
      )
    end
  end
end
