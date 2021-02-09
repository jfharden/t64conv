module T64conv
  module FileHandlers
    # Base handler for any file which is not an archive or directory
    class BaseFlatFileHandler
      # Looking for a number surrounded by parentehses as the final thing in a string (even multi-line) other than
      # whitespace. This extracts the number only and returns it as a capture
      VERSION_NUMBER_REGEXP = Regexp.new(/\(([0-9]+)\)\s*\Z/)

      def initialize(path, output_dir, dryrun)
        @path = File.expand_path(path)
        @output_dir = output_dir
        @dryrun = dryrun

        raise ArgumentError, "Source filepath #{path} does not exist" unless File.exist?(path)
        raise ArgumentError, "Output directory #{output_dir} does not exist" if _invalid_output_directory

        @source_dir = File.dirname(path)
        @source_file = File.basename(path)
      end

      def handle
        _create_output_dir
        _copy_file
        _copy_version_nfo
      end

      def _invalid_output_directory
        return if @dryrun

        !File.directory?(@output_dir)
      end

      def _create_output_dir
        return if @dryrun

        FileUtils.mkdir_p(_destination_directory)
      end

      def _copy_file
        _info_msg("Copying #{@path} -> #{_destination_fullpath}")
        FileUtils.cp(@path, _destination_fullpath) unless @dryrun
      end

      def _copy_version_nfo
        unless _version_nfo_source_filename
          _info_msg("No VERSION.nfo to copy in #{@source_dir}")
          return
        end

        _info_msg("Copying #{_version_nfo_source_fullpath} -> #{_version_nfo_destination_fullpath}")

        FileUtils.cp(
          _version_nfo_source_fullpath,
          _version_nfo_destination_fullpath
        ) unless @dryrun
      end

      def _destination_fullpath
        @destination_fullpath ||= File.join(_destination_directory, _destination_filename)
      end

      def _destination_directory
        @destination_directory ||= File.join(*[
          @output_dir,
          _alphabetic_directory,
          File.basename(_destination_filename, ".*"),
          _version_number
        ].compact)
      end

      def _destination_filename
        @destination_filename ||= @source_file.upcase
      end

      def _alphabetic_directory
        @source_file[0].upcase
      end

      # Returns either the version number (as a string) or nil
      def _version_number
        VERSION_NUMBER_REGEXP.match(File.basename(@source_dir))&.captures&.first
      end

      def _version_nfo_destination_fullpath
        File.join(_destination_directory, _version_nfo_source_filename.upcase)
      end

      def _version_nfo_source_fullpath
        @version_nfo_source_fullpath ||= File.join(@source_dir, _version_nfo_source_filename)
      end

      def _version_nfo_source_filename
        @version_nfo_source_filename ||= Dir.foreach(@source_dir) do |file|
          return file if file.downcase == "version.nfo"
        end
      end

      def _info_msg(message)
        puts(message) if @dryrun
      end
    end
  end
end
