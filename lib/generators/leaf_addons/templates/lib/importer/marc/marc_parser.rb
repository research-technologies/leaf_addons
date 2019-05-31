# frozen_string_literal: true
require 'marc'
module Importer
  module Marc
    class MarcParser
      include Enumerable
      include LeafAddons::Importer::Marc::MarcAttributes
      # For locally overriden methods
      include Importer::Marc::MarcAttributesOverrides

      attr_accessor :file_name, :attributes
      attr_writer :marc_mappings

      def initialize(file_name)
        @file_name = file_name
      end

      # @yieldparam attributes [Hash] the attributes from one marc record
      def each(&_block)
        ::MARC::Reader.new(file_name).each do |marc|
          create_attributes(marc)
          yield attributes
        end
      end
    end
  end
end
