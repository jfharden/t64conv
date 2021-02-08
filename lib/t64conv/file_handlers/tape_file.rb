require "open3"

require_relative "./base_flat_file"

module T64conv
  module FileHandlers
    # Handles t64 files
    class TapeFileHandler < BaseFlatFileHandler
      def _copy_file
        _info_msg("Converting #{@path} -> #{_destination_fullpath}")

        return if @dryrun

        output, status = Open3.capture2e(_conversion_command)

        return if status.success?

        warn("Conversion of #{@path} -> #{_destination_fullpath} failed.")
        warn("Command was #{_conversion_command}. Output from c1541 follows:")
        warn("----\n#{output}----\n\n")
      end

      def _destination_filename
        @destination_filename ||= "#{File.basename(@source_file.upcase, '.*')}.D64"
      end

      def _destination_filename_no_extension
        File.basename(_destination_filename, ".*")
      end

      def _conversion_command
        @conversion_command ||= "c1541 " \
          "-format '#{_destination_filename_no_extension},00' " \
          "d64 '#{_destination_fullpath}' " \
          "8 -tape '#{@path}'"
      end
    end
  end
end
