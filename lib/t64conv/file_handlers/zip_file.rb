require_relative './directory_traverser'

require 'zip'

module T64conv
  module FileHandlers
    # Handles zip files
    # If the zip file contains a t64, d64, or other zip file:
    #   1. then a temp directory will be created.
    #   2. In that temp directory another directory with the name of the zip file (minus it's extension) will be created
    #   3. The contents of the zip file will be extracted to that subdirectory.
    #   4. Traversal of that subdirectory will be initiated
    class ZipFileHandler
      def initialize(path, tape_converter, dryrun)
        @path = path
        @tape_converter = tape_converter
        @dryrun = dryrun
      end

      def handle
        return unless _zip_interesting?

        # Make a temp dir for extraction
        Dir.mktmpdir('t64conv-') do |tmpdir|
          # Make a directory in the tempdir which has the name of the zipfile without it's extension
          zip_name_no_ext = File.basename(@path, '.*')

          _extract_and_traverse(File.join(tmpdir, zip_name_no_ext))
        end
        # Make a tempdir
        # extract into a subdir of the tempdir with the zip file name
        # discover on the subdir
      end

      def _zip_interesting?
        Zip::File.foreach(@path) do |archive|
          extension = File.extname(archive).downcase

          return true if %w[t64 d64 zip].include?(extension)
        end

        false
      end

      def _extract_and_traverse(unzip_destination)
        Dir.mkdir(unzip_destination) do
          # Extract the zip into the directory with the same name as the zip
          Zip::Zipfile.open(@path) do |zipfile|
            zipfile.each do |zip_entry|
              zipfile.extract(zip_entry, unzip_destination)
            end
          end

          DirectoryTraverser(unzip_destination, @tape_converter, dryrun)
        end
      end
    end
  end
end