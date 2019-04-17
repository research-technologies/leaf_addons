# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength

module LeafAddons
  module Importer
    module Marc
      module MarcAttributes
        mattr_accessor :marc_mappings
        # Mapping from the property name to the code and subfield in the marc record
        #   A property can have multiple marc fields mapped to it
        self.marc_mappings =
          {
            creator: [
              { code: '100', subfield: 'a' },
              { code: '110', subfield: 'a' },
              { code: '700', subfield: 'a' },
              { code: '710', subfield: 'a' }
            ],
            title: [{ code: '245', subfield: 'a' }],
            alt_title: [{ code: '246', subfield: 'a' }],
            place_of_publication: [{ code: '260', subfield: 'a' }],
            publisher: [{ code: '260', subfield: 'b' }],
            date_published: [{ code: '260', subfield: 'c' }],
            abstract: [{ code: '520', subfield: 'a' }],
            subject: [{ code: '650', subfield: 'a' }],
            isbn: [{ code: '20', subfield: nil }],
            issn: [{ code: '22', subfield: nil }],
            pagination: [{ code: '300', subfield: 'a' }],
            official_url: [{ code: '856', subfield: 'u' }],
            part: [{ code: '248', subfield: 'a' }],
            note: [{ code: '500', subfield: 'a' }]
          }

        # Build the attributes for passing to Fedora
        #
        # @param marc [MARC::Record]
        attr_accessor :marc
        def create_attributes(marc)
          @attributes = {}
          @marc = marc
          standard_attributes
          special_attributes
          attributes[:id] = make_identifier(marc['999']['d'])
          attributes[:model] = find_model(marc['952']['y'])
          add_to_attributes(:resource_type, find_resource_type(marc['952']['y']))
          # rescue StandardError
          #   warning ||= marc['999']['d'] unless marc['999'].blank?
          #   warn("\nSomething went wrong when processing #{warning} - skipping this line - check logs for details")
          #   Rails.logger.warn "Something went wrong with #{warning} (#{$ERROR_INFO})"
        end

        # Iterate over the marc mappings, extracting data from the marc record
        #
        # @param marc [MARC::Record] the marc record
        def standard_attributes
          marc_mappings.each_key do |key|
            val ||= attribute_value(key)
            add_to_attributes(key, val) unless val.blank?
          end
        end

        # Extract the value from the marc record
        #
        # @param marc [MARC::Record] the marc record
        # @param attribute [Sumbol] the attribute name
        def attribute_value(att)
          return if special_attributes_list.include?(att)
          value = []

          marc_mappings[att].each do |map|
            next if marc[map[:code]].blank?
            if map[:subfield].blank?
              value += marc_field_data(map[:code])
            else
              next if marc[map[:code]][map[:subfield]].blank?
              value += marc_subfield_data(map[:code], map[:subfield])
            end
          end
          value.select { |n| !n.nil? }
        end

        def marc_field_data(code)
          marc.select { |m| m.tag == code }.collect { |m| cleanup_data(m.value) }
        end

        def marc_subfields(code)
          marc.select { |marctag| marctag.tag == code }.collect { |m| m.subfields if m.tag == code }
        end

        def marc_subfield_data(code, subfield)
          marc_subfields(code).collect { |sf| sf.collect { |val| cleanup_data(val.value) if val.code == subfield } }.flatten
        end

        # Add value to attributes
        #
        # @param attribute [Symbol] the attribute
        # @param value [String] the value
        def add_to_attributes(att, value)
          return if value.blank?
          if attributes[att].blank?
            attributes[att] = Array.wrap(value)
          else
            attributes[att] += Array.wrap(value)
          end
        end

        # Determine the model for each marc item_type
        #   override for custom mappings, like so:
        # def find_model(type)
        #   case type
        #     when 'CONFERENCEPAPER'
        #       'ConferenceItem'
        #     else
        #       'PublishedWork'
        #     end
        # end
        #
        # @param [String] the marc type value
        # @return [String] the Model name
        def find_model(_type)
          'PublishedWork'
        end

        # creator / editor
        def special_attributes_list
          [:creator]
        end

        # Generate any special attributes
        #
        # @param marc [MARC::Record] the marc record
        def special_attributes
          special_attributes_list.each do |special|
            send(special)
          end
        end

        # Add creators, editors and contributors
        #
        # @param marc [MARC::Record] the marc record
        # @param attribute [Symbol] the attribute
        def creator
          marc_mappings[:creator].each do |map|
            next if marc[map[:code]].blank?
            marc_subfields(map[:code]).each do |sf|
              creator_subfield(sf)
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def creator_subfield(subfield)
          if subfield.length == 1
            add_to_attributes(:creator, subfield.first.value)
          elsif subfield.collect { |c| true if c.code == 'e' && c.value.include?('editor') }.include?(true)
            subfield.collect { |v| v.value if v.code == 'a' }.first
            add_to_attributes(:editor, subfield.collect { |v| v.value if v.code == 'a' }.first)
          elsif subfield.collect { |c| true if c.code == 'e' }.include?(true)
            add_to_attributes(:contributor, subfield.collect { |v| v.value if v.code == 'a' }.first)
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        def find_resource_type(type)
          type.titleize
        end

        # Trim whitespace and commas / colons from end of text
        def cleanup_data(text)
          text.chomp(' ').chomp(':').chomp(',').chomp(' ')
        end

        # Pad out the identifier with zeros
        #   append zeros up to 9 chars (noids have 9 chars)
        #   if it's already 9 or over, return it
        #
        # @param marcid [String] the marc identifier
        # @return [String] the padded identifier
        def make_identifier(marcid)
          return marcid if marcid.to_s.length >= 9
          marcid.to_s.rjust(9, '0')
        end
      end
    end
  end
end

# rubocop:enable Metrics/ModuleLength
