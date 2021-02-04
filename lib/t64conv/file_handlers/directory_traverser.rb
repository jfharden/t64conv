require_relative "./disk_file"
require_relative "./tape_file"
require_relative "./zip_file"

module T64conv
  module FileHandlers
    # Reads a directories contents and triggers the appropriate handlers for the type of file
    class DirectoryTraverser
      def initialize(directory, tape_converter, dryrun)
        raise ArgumentError, "#{directory} is not a directory" unless File.directory?(directory)

        @directory = directory
        @tape_converter = tape_converter
        @dryrun = dryrun
      end

      def discover
        Dir.foreach(@directory) do |file|
          next if %w[. ..].include?(File.basename(file))

          fullpath = File.expand_path(File.join(@directory, file))

          if File.directory?(fullpath)
            DirectoryTraverser.new(fullpath, @tape_converter, @dryrun).discover
            next
          end

          _handle_file(fullpath)
        end
      end

      def _handle_file(path)
        case File.extname(path).downcase
        when ".t64"
          TapeFileHandler.new(path, @tape_converter, @dryrun).handle
        when ".d64"
          DiskFileHandler.new(path, @tape_converter, @dryrun).handle
        when ".zip"
          ZipFileHandler.new(path, @tape_converter, @dryrun).handle
        end
      end
    end
  end
end
