# frozen_string_literal: true

module Importer
  # Imports Marc metadata
  module Marc
    class MarcImporter
      attr_accessor :model, :metadata_file

      def initialize(metadata_file)
        @metadata_file = metadata_file
      end

      # Import the items
      #
      # @return count of items imported
      def import_all
        count = 0
        parser.each do |attributes|
          next if attributes.blank?
          next if attributes[:model].blank?
          @model = attributes[:model]
          attributes.delete(:model)
          attributes[:edit_groups] = ['admin']
          create_fedora_objects(attributes)
          count += 1
        end
        message = "Imported #{count} record(s).\n"
        message
      end

      private

        # Create a parser object with the metadata file
        def parser
          Marc::MarcParser.new(metadata_file)
        end

        # Build a factory to create the objects in fedora.
        #
        # @param attributes [Hash] the object attributes
        def create_fedora_objects(attributes)
          Factory.for(model).new(attributes).run
        end
    end
  end
end
