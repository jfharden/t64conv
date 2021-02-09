require_relative "./directory_traverser"

require "zip"

module T64conv
  module FileHandlers
    # Handles zip files
    # If the zip file contains a t64, d64, or other zip file:
    #   1. then a temp directory will be created.
    #   2. In that temp directory another directory with the name of the zip file (minus it's extension) will be created
    #   3. The contents of the zip file will be extracted to that subdirectory.
    #   4. Traversal of that subdirectory will be initiated
    class ZipFileHandler
      def initialize(path, output_dir, dryrun)
        @path = path
        @output_dir = output_dir
        @dryrun = dryrun
      end

      def handle
        return unless zip_interesting?

        # Make a temp dir for extraction
        Dir.mktmpdir("t64conv-") do |tmpdir|
          # Make a directory in the tempdir which has the name of the zipfile without it's extension
          zip_name_no_ext = File.basename(@path, ".*")

          _extract_and_traverse(File.join(tmpdir, zip_name_no_ext))
        end
      end

      def zip_interesting?
        Zip::File.foreach(@path) do |archive|
          extension = File.extname(archive.name).downcase
          if %w[.t64 .d64 .zip].include?(extension)
            _info_msg("ZIP File #{@path} contains a T64, D64, or ZIP file, extracting")
            return true
          end
        end

        _info_msg("ZIP File #{@path} does not contain any T64, D64, or ZIP files.")
        false
      end

      def _extract_and_traverse(unzip_destination)
        Dir.mkdir(unzip_destination)

        _info_msg("ZIP extracting to #{unzip_destination} for traversal")

        # Extract the zip into the directory with the same name as the zip
        Zip::File.open(@path) do |zipfile|
          zipfile.each do |zip_entry|
            extract_to = File.join(unzip_destination, zip_entry.name)
            zipfile.extract(zip_entry, extract_to)
          end
        end

        DirectoryTraverser.new(unzip_destination, @output_dir, @dryrun).discover
      end

      def _info_msg(message)
        puts(message) if @dryrun
      end
    end
  end
end
