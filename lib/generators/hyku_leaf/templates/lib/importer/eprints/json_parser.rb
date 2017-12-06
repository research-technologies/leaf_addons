# frozen_string_literal: true

module Importer
  module Eprints
    class JsonParser
      include Enumerable
      include HykuLeaf::Importer::Eprints::JsonAttributes
      include HykuLeaf::Importer::Eprints::JsonDownloader
      # For locally overriden methods
      include Importer::Eprints::JsonAttributesOverrides

      def initialize(file_name, downloads_directory)
        @file_name = file_name
        @downloads = downloads_directory
      end

      # @yieldparam attributes [Hash] the attributes from one eprint
      def each(&_block)
        JSON.parse(File.read(@file_name)).each do |eprint|
          yield(attributes(eprint))
        end
      end
    end
  end
end
