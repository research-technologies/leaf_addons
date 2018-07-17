# frozen_string_literal: true

module Importer
  module Eprints
    class JsonParser
      include Enumerable
      include LeafAddons::Importer::Eprints::JsonAttributes
      include LeafAddons::Importer::Eprints::JsonDownloader
      # For locally overriden methods
      include Importer::Eprints::JsonAttributesOverrides

      attr_accessor :attributes

      def initialize(file_name, downloads_directory)
        @file_name = file_name
        @downloads = downloads_directory
      end

      # @yieldparam attributes [Hash] the attributes from one eprint
      def each(&_block)
        JSON.parse(File.read(@file_name)).each do |eprint|
          create_attributes(eprint)
          yield attributes
        end
      end
    end
  end
end
