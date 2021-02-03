module T64conv
  module FileHandlers
    # Base handler for any file which is not an archive or directory
    class BaseFlatFileHandler
      def initialize(path, tape_converter, dryrun)
        @path = path
        @tape_converter = tape_converter
        @dryrun = dryrun
      end

      def handle
        raise NotImplementedError, "Must be implemented in concrete subclass"
      end
    end
  end
end
