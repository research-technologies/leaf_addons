# frozen_string_literal: true

module Importer
  # Import an Eprints3 json file.
  module Eprints
    class JsonImporter
      def initialize(metadata_file, downloads_directory)
        @model = 'Object'
        @metadata_file = metadata_file
        @downloads = downloads_directory
        @files = [] # don't send any files
      end

      # Import the items
      #
      # @return count of items imported
      def import_all
        count = 0
        ids = []
        parser.each do |attributes|
          @model = attributes[:model]
          attributes.delete(:model)
          attributes[:edit_groups] = ['admin']
          create_fedora_objects(attributes)
          count += 1
        end
        # Update filesets with extracted_text
        #   do this as a separate step to allow jobs to complete
        ids.each do |work|
          id = work.keys.first
          add_to_work_filesets(id, work[id])
        end
        message = "Imported #{count} record(s).\n"
        message += "Files have been downloaded to #{@downloads}\n"
        message += "A list of files with their visibility has been written to #{@downloads}/downloaded_files.csv"
        message += "Import with:\n"
        message += "  bin/import_files_to_existing_objects `hostname` #{@downloads}/import_files.csv #{@downloads} 1"
        message
      end

      private

        # Create a parser object with the metadata file
        def parser
          Eprints::JsonParser.new(@metadata_file, @downloads)
        end

        # Build a factory to create the objects in fedora.
        #
        # @param attributes [Hash] the object attributes
        def create_fedora_objects(attributes)
          Factory.for(@model).new(attributes).run
        end
    end
  end
end
