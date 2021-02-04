module T64conv
  module FileHandlers
    # Base handler for any file which is not an archive or directory
    class BaseFlatFileHandler
      def initialize(path, tape_converter, output_dir, dryrun)
        @path = path
        @tape_converter = tape_converter
        @output_dir = output_dir
        @dryrun = dryrun
      end

      def handle
        raise NotImplementedError, "Must be implemented in concrete subclass"
      end
    end
  end
end
