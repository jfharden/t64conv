require_relative "./disk_file"
require_relative "./tape_file"
require_relative "./zip_file"

module T64conv
  module FileHandlers
    # Reads a directories contents and triggers the appropriate handlers for the type of file
    class DirectoryTraverser
      def initialize(directory, output_dir, dryrun)
        raise ArgumentError, "#{directory} is not a directory" unless File.directory?(directory)
        raise ArgumentError, "output directory #{output_dir} is not a directory" unless File.directory?(output_dir)

        @directory = directory
        @output_dir = output_dir
        @dryrun = dryrun
      end

      def discover
        Dir.foreach(@directory) do |file|
          next if %w[. ..].include?(File.basename(file))

          fullpath = File.expand_path(File.join(@directory, file))

          if File.directory?(fullpath)
            DirectoryTraverser.new(fullpath, @output_dir, @dryrun).discover
            next
          end

          _handle_file(fullpath)
        end
      end

      def _handle_file(path)
        handler_class =
          case File.extname(path).downcase
          when ".t64"
            TapeFileHandler
          when ".d64"
            DiskFileHandler
          when ".zip"
            ZipFileHandler
          end

        handler_class&.new(path, @output_dir, @dryrun)&.handle
      end
    end
  end
end
