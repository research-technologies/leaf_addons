module Importer
  class FilesParser
    include Enumerable

    # Initialize
    #
    # @param metadata_file [String] path to the metadata csv file
    # @param files_directory [String] path of the directory containing the files to ingest
    # @param depth [FixNum] the directory depth at which to find the files
    def initialize(metadata_file, files_directory, depth)
      @file_name = metadata_file
      @directory = files_directory
      @depth = depth.to_i
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&_block)
      CSV.foreach(@file_name) do |row|
        yield [row[0],build_files_hash(row[1])]
      end
    end

    private

      # Build a hash of files to be ingested, using the depth to recurse the correct number of directories
      #
      # @param directory_or_file [String] the directory or filename from the csv
      # @return hash of files
      def build_files_hash(directory_or_file)
        if @depth == 0
          file = File.join(@directory, directory_or_file)
          return [] unless File.file?(file)
          build_files([file])
        elsif @depth > 0
          dir = File.join(@directory,directory_or_file)
          return [] unless File.directory?(dir)
          build_files(build_file_path(dir))
        end
      end

      # Build a hash of paths
      #
      # @param path [String] the directory to start from
      # @return hash of file paths
      def build_file_path(path)
        i = @depth
        while i > 0
          path = "#{path}/*"
          i -= 1
        end
        # Reject directories. Once we reach the specified depth, we want files only.
        Dir.glob(path).reject{ |e| File.directory? e }
      end

      # Build an array of files
      #
      # @param files [Hash] hash of file paths
      # @return array of files
      def build_files(files)
        files_array = []
        files.each do | file |
          u = Hyrax::UploadedFile.new
          unless User.find_by_user_key( User.batch_user_key ).nil?
            u.user_id = User.find_by_user_key( User.batch_user_key ).id
          end
          u.file = CarrierWave::SanitizedFile.new(file)
          u.save
          files_array <<  u.id
        end
        files_array
      end

  end
end
