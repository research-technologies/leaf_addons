# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

module LeafAddons
  module Importer
    module Eprints
      module JsonAttributes
        # Build the attributes for passing to Fedora

        # @param eprint [Hash] json for a single eprint
        # @return [Hash] attributes
        def attributes(eprint)
          attributes = standard_attributes(eprint)
          attributes = special_attributes(eprint, attributes)
          attributes[:model] = find_model(eprint['type'])
          attributes
        rescue StandardError
          warn("\nSomething went wrong when processing #{eprint['eprintid']} - skipping this line - check logs for details")
          Rails.logger.warn "Something went wrong with #{eprint['eprintid']} (#{$ERROR_INFO.message})"
        end

        # Build the standard attributes (those that can be called with just the name, value and attributes)

        # @param eprint [Hash] json for a single eprint
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def standard_attributes(eprint)
          attributes = {}
          eprint.each do |k, v|
            next if ignored.include?(k) || special.include?(k)
            if respond_to?(k.to_sym)
              attributes = method(k).call(v, attributes)
            else
              warn "\nNo method exists for field #{k}"
              Rails.logger.warn "No method for field #{k}"
            end
          end
          attributes
        end

        # Build the special attributes (those that need more than just name and value)
        #
        # @param eprint [Hash] json for a single eprint
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def special_attributes(eprint, attributes)
          documents(eprint['documents'], eprint['eprintid']) unless eprint['documents'].nil?
          attributes.merge!(event_title(eprint['event_title'], eprint['event_type']))
          attributes.merge!(date(eprint['date'], eprint['date_type']))
          attributes.merge!(access_setting(eprint['metadata_visibility'], eprint['eprint_status']))
          attributes
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/MethodLength

        # Determine the model for each eprint['type']
        # Supports ootb eprints types:
        #   Article, Book, Monograph, Conference Item, Thesis,
        #   Dataset, Experiment
        # Everything else mapped to 'GenericWork'
        #
        # @param [String] the eprint type value
        # @return [String] the Model name
        def find_model(type)
          case type
          when 'article'
            'JournalArticle'
          when 'book_section'
            'PublishedWork'
          when 'monograph'
            'PublishedWork'
          when 'book'
            'PublishedWork'
          when 'conference_item'
            'ConferenceItem'
          when 'thesis'
            'Thesis'
          when 'dataset'
            'Dataset'
          when 'experiment'
            'Dataset'
          else
            'GenericWork'
          end
        end

        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/MethodLength

        # Default mappings from EPrints to Hyku

        # Fields to ignore when processing an eprint json
        #
        # @return [Array] ignored fields
        def ignored
          [
            'lastmod',
            'uri',
            'status_changed',
            'rev_number',
            'datestamp',
            'dir',
            'source',
            'userid',
            'full_text_status'
          ]
        end

        # Fields that need special treatment when processing an eprint json
        #
        # @return [Array] special fields
        def special
          [
            'date',
            'date_type',
            'metadata_visibility',
            'eprint_status',
            'event_type',
            'event_title',
            'documents'
          ]
        end

        # Special fields

        # Use metadata_visibility and eprint_status to construct this
        def access_setting(metadata_visibility, eprint_status)
          if metadata_visibility == 'show' && eprint_status == 'archive'
            { visibility: 'open' }
          else
            { visibility: 'restricted' }
          end
        end

        # Add date to attributes
        #
        # @param val [String] the date value
        # @param type [String] the date type
        # @return [Hash] date hash
        def date(val, type)
          # TODO: extend to other date types
          case type
          when 'published'
            { date_published: [val.to_s] }
          else
            { date: [val.to_s] }
          end
        end

        # Process the documents hash
        #
        # @param val [Hash] the value
        def documents(val, eprintid)
          download(val, eprintid) if val.present?
        end

        # TODO: create 'event' and add lookup
        # Add event_title to attributes
        #
        # @param val [String] the event_title value
        # @param event_type [String] the event type, unless nil
        # @return [Hash] event_title hash
        def event_title(val, event_type)
          event = val
          event += " (#{event_type})" unless event.nil? || event_type.blank?
          event.blank? ? {} : { presented_at: [event.to_s] }
        end

        # Standard fields

        # TODO: should this be a separate field? schema alternative name?
        # Add alt_title to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def alt_title(val, attributes)
          if attributes[:title].blank?
            attributes[:title] = [val]
          else
            attributes[:title] << val
          end
          attributes
        end

        # TODO: create 'organisation' and lookup
        # Add corp_creators to attributes
        #
        # @param val [Array] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def corp_creators(val, attributes)
          attributes[:creator] ||= []
          val.each do |corp|
            attributes[:creator] << corp
          end
          attributes.delete(:creator) if attributes[:creator] == []
          attributes
        end

        # TODO: create 'person' and lookup
        # Add creators to attributes
        #
        # @param val [Array] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def creators(val, attributes)
          attributes[:creator] ||= []
          val.each do |cr|
            name = make_name(cr)
            attributes[:creator] << name if name.present?
          end
          attributes.delete(:creator) if attributes[:creator] == []
          attributes
        end

        # TODO: create 'person' and lookup
        # Add editors to attributes
        #
        # @param val [Array] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def editors(val, attributes)
          attributes[:editor] ||= []
          val.each do |ed|
            name = make_name(ed)
            attributes[:editor] << name if name.present?
          end
          attributes.delete(:editor) if attributes[:editor] == []
          attributes
        end

        # TODO: create 'organisation' and lookup
        # Add contributors to attributes
        #
        # @param val [Array] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def contributors(val, attributes)
          attributes[:contributor] ||= []
          val.each do |co|
            name = make_name(co)
            attributes[:contributor] << name if name.present?
          end
          attributes.delete(:contributor) if attributes[:contributor] == []
          attributes
        end

        # Add abstract to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def abstract(val, attributes)
          attributes[:abstract] = [val]
          attributes
        end

        # Add divisions to attributes
        # This will likely be overridden with a lookup
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def divisions(val, attributes)
          attributes[:department] = []
          val.each do |v|
            attributes[:department] << v.to_s
          end
          attributes
        end

        # Add edition to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def edition(val, attributes)
          attributes[:edition] = [val.to_s]
          attributes
        end

        # Add eprintid to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def eprintid(val, attributes)
          attributes[:former_id] = [val.to_s]
          attributes[:id] = make_identifier(val)
          attributes
        end

        # Add event_dates to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def event_dates(val, attributes)
          attributes[:event_date] = [val.to_s]
          attributes
        end

        # Add event_location to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def event_location(val, attributes)
          attributes[:event_location] = [val.to_s]
          attributes
        end

        # Add isbn to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def isbn(val, attributes)
          attributes[:isbn] = [val.to_s]
          attributes
        end

        # Add ispublished to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def ispublished(val, attributes)
          attributes[:publication_status] = case val
                                            when 'pub'
                                              ['published']
                                            when 'unpub'
                                              ['unpublished']
                                            else
                                              [val.to_s]
                                            end
          attributes
        end

        # Add keywords to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def keywords(val, attributes)
          attributes[:keyword] = val.split(',').collect(&:strip)
          attributes
        end

        # Add latitude to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def latitude(val, attributes)
          attributes[:lat] = [val.to_s]
          attributes
        end

        # Add longitude to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def longitude(val, attributes)
          attributes[:long] = [val.to_s]
          attributes
        end

        # Add note to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def note(val, attributes)
          attributes[:note] = [val]
          attributes
        end

        # Add number to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def number(val, attributes)
          attributes[:issue_number] = [val.to_s]
          attributes
        end

        # Add official_url to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def official_url(val, attributes)
          attributes[:official_url] = [val.to_s]
          attributes
        end

        # Add pages to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def pages(val, attributes)
          attributes[:pagination] = [val.to_s]
          attributes
        end

        # Add pagerange to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def pagerange(val, attributes)
          attributes[:pagination] = [val.to_s]
          attributes
        end

        # Add part to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def part(val, attributes)
          attributes[:part] = [val]
          attributes
        end

        # Add place_of_pub to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def place_of_pub(val, attributes)
          attributes[:place_of_publication] = [val]
          attributes
        end

        # Add pres_type to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def pres_type(val, attributes)
          if attributes[:resource_type].blank?
            attributes[:resource_type] = [find_type(val)]
          else
            attributes[:resource_type] << find_type(val)
          end
          attributes
        end

        # Add publication to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def publication(val, attributes)
          attributes[:part_of] = [val]
          attributes
        end

        # TODO: ensure value is in resource types list
        def find_type(type)
          type.titleize
        end

        # Add publisher to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def publisher(val, attributes)
          attributes[:publisher] = [val]
          attributes
        end

        # Add refereed to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def refereed(val, attributes)
          attributes[:refereed] = if val == 'TRUE'
                                    ['Yes']
                                  else
                                    ['No']
                                  end
          attributes
        end

        # Add series to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def series(val, attributes)
          attributes[:series] = [val.to_s]
          attributes
        end

        # Add subjects to attributes
        # This will likely be overridden with a lookup
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def subjects(val, attributes)
          attributes[:subject] = []
          val.each do |v|
            attributes[:subject] << v.to_s
          end
          attributes
        end

        # Add title to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def title(val, attributes)
          if attributes[:title].blank?
            attributes[:title] = [val]
          else
            attributes[:title] << val
          end
          attributes
        end

        # Add type to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def type(val, attributes)
          if attributes[:resource_type].blank?
            attributes[:resource_type] = [find_type(val)]
          else
            attributes[:resource_type] << find_type(val)
          end
          attributes
        end

        # Add volume to attributes
        #
        # @param val [String] the value
        # @param attributes [Hash] hash of attributes to update
        # @return [Hash] attributes
        def volume(val, attributes)
          attributes[:volume_number] = [val.to_s]
          attributes
        end

        # Create a name string from parts
        #
        # @param name [Hash] name parts
        # @return [Hash] name string
        def make_name(name)
          "#{name['name']['family']}, #{name['name']['given']}"
        end

        # Pad out the identifier with zeros
        #   append zeros up to 9 chars (noids have 9 chars)
        #   if it's already 9 or over, return it
        #
        # @param eprintid [String] the eprint identifier
        # @return [String] the padded identifier
        def make_identifier(eprintid)
          return eprintid if eprintid.to_s.length >= 9
          eprintid.to_s.rjust(9, '0')
        end
      end
    end
  end
end

# rubocop:enable Metrics/ModuleLength
