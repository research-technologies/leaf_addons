# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

module LeafAddons
  module Importer
    module Eprints
      module JsonAttributes
        # Build the attributes for passing to Fedora
        #
        # @param eprint [Hash] json for a single eprint
        def create_attributes(eprint)
          @attributes = {}
          standard_attributes(eprint)
          special_attributes(eprint)
          attributes[:model] = find_model(eprint['type'])
        rescue StandardError
          warn("\nSomething went wrong when processing #{eprint['eprintid']} - skipping this line - check logs for details")
          Rails.logger.warn "Something went wrong with #{eprint['eprintid']} (#{$ERROR_INFO})"
        end

        # Build the standard attributes (those that can be called with just the name, value and attributes)

        # @param eprint [Hash] json for a single eprint
        def standard_attributes(eprint)
          eprint.each do |k, v|
            next if ignored.include?(k) || special.include?(k)
            if respond_to?(k.to_sym)
              method(k).call(v)
            else
              warn "\nNo method exists for field #{k}"
              Rails.logger.warn "No method for field #{k}"
            end
          end
        end

        # Build the special attributes (those that need more than just name and value)
        #
        # @param eprint [Hash] json for a single eprint
        def special_attributes(eprint)
          documents(eprint['documents'], eprint['eprintid']) unless eprint['documents'].nil?
          attributes.merge!(event_title(eprint['event_title'], eprint['event_type']))
          attributes.merge!(date(eprint['date'], eprint['date_type']))
          attributes.merge!(access_setting(eprint['metadata_visibility'], eprint['eprint_status']))
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
          when 'book_section'
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
        def alt_title(val)
          if attributes[:title].blank?
            attributes[:title] = [val]
          else
            attributes[:title] << val
          end
        end

        # TODO: create 'organisation' and lookup
        # Add corp_creators to attributes
        #
        # @param val [Array] the value
        def corp_creators(val)
          attributes[:creator] ||= []
          val.each do |corp|
            attributes[:creator] << corp
          end
          attributes.delete(:creator) if attributes[:creator] == []
        end

        # TODO: create 'person' and lookup
        # Add creators to attributes
        #
        # @param val [Array] the value
        def creators(val)
          attributes[:creator] ||= []
          val.each do |cr|
            name = make_name(cr)
            attributes[:creator] << name if name.present?
          end
          attributes.delete(:creator) if attributes[:creator] == []
        end

        # TODO: create 'person' and lookup
        # Add editors to attributes
        #
        # @param val [Array] the value
        def editors(val)
          attributes[:editor] ||= []
          val.each do |ed|
            name = make_name(ed)
            attributes[:editor] << name if name.present?
          end
          attributes.delete(:editor) if attributes[:editor] == []
        end

        # TODO: create 'organisation' and lookup
        # Add contributors to attributes
        #
        # @param val [Array] the value
        def contributors(val)
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
        def abstract(val)
          attributes[:abstract] = [val]
          attributes
        end

        # Add divisions to attributes
        # This will likely be overridden with a lookup
        #
        # @param val [String] the value
        def divisions(val)
          attributes[:department] = []
          val.each do |v|
            attributes[:department] << v.to_s
          end
        end

        # Add edition to attributes
        #
        # @param val [String] the value
        def edition(val)
          attributes[:edition] = [val.to_s]
        end

        # Add eprintid to attributes
        #
        # @param val [String] the value
        def eprintid(val)
          attributes[:former_id] = [val.to_s]
          attributes[:id] = make_identifier(val)
        end

        # Add event_dates to attributes
        #
        # @param val [String] the value
        def event_dates(val)
          attributes[:event_date] = [val.to_s]
        end

        # Add event_location to attributes
        #
        # @param val [String] the value
        def event_location(val)
          attributes[:event_location] = [val.to_s]
        end

        # Add isbn to attributes
        #
        # @param val [String] the value
        def isbn(val)
          attributes[:isbn] = [val.to_s]
        end

        # Add ispublished to attributes
        #
        # @param val [String] the value
        def ispublished(val)
          attributes[:publication_status] = case val
                                            when 'pub'
                                              ['published']
                                            when 'unpub'
                                              ['unpublished']
                                            else
                                              [val.to_s]
                                            end
        end

        # Add keywords to attributes
        #
        # @param val [String] the value
        def keywords(val)
          attributes[:keyword] = val.split(',').collect(&:strip)
        end

        # Add latitude to attributes
        #
        # @param val [String] the value
        def latitude(val)
          attributes[:lat] = [val.to_s]
        end

        # Add longitude to attributes
        #
        # @param val [String] the value
        def longitude(val)
          attributes[:long] = [val.to_s]
        end

        # Add note to attributes
        #
        # @param val [String] the value
        def note(val)
          attributes[:note] = [val]
        end

        # Add number to attributes
        #
        # @param val [String] the value
        def number(val)
          attributes[:issue_number] = [val.to_s]
        end

        # Add official_url to attributes
        #
        # @param val [String] the value
        def official_url(val)
          attributes[:official_url] = [val.to_s]
        end

        # Add pages to attributes
        #
        # @param val [String] the value
        def pages(val)
          attributes[:pagination] = [val.to_s]
        end

        # Add pagerange to attributes
        #
        # @param val [String] the value
        def pagerange(val)
          attributes[:pagination] = [val.to_s]
        end

        # Add part to attributes
        #
        # @param val [String] the value
        def part(val)
          attributes[:part] = [val]
        end

        # Add place_of_pub to attributes
        #
        # @param val [String] the value
        def place_of_pub(val)
          attributes[:place_of_publication] = [val]
        end

        # Add pres_type to attributes
        #
        # @param val [String] the value
        def pres_type(val)
          if attributes[:resource_type].blank?
            attributes[:resource_type] = [find_type(val)]
          else
            attributes[:resource_type] << find_type(val)
          end
        end

        # Add publication to attributes
        #
        # @param val [String] the value
        def publication(val)
          attributes[:part_of] = [val]
        end

        # TODO: ensure value is in resource types list
        def find_type(type)
          type.titleize
        end

        # Add publisher to attributes
        #
        # @param val [String] the value
        def publisher(val)
          attributes[:publisher] = [val]
        end

        # Add refereed to attributes
        #
        # @param val [String] the value
        def refereed(val)
          attributes[:refereed] = if val == 'TRUE'
                                    ['Yes']
                                  else
                                    ['No']
                                  end
        end

        # Add series to attributes
        #
        # @param val [String] the value
        def series(val)
          attributes[:series] = [val.to_s]
        end

        # Add subjects to attributes
        # This will likely be overridden with a lookup
        #
        # @param val [String] the value
        def subjects(val)
          attributes[:subject] = []
          val.each do |v|
            attributes[:subject] << v.to_s
          end
        end

        # Add title to attributes
        #
        # @param val [String] the value
        def title(val)
          if attributes[:title].blank?
            attributes[:title] = [val]
          else
            attributes[:title] << val
          end
        end

        # Add type to attributes
        #
        # @param val [String] the value
        def type(val)
          if attributes[:resource_type].blank?
            attributes[:resource_type] = [find_type(val)]
          else
            attributes[:resource_type] << find_type(val)
          end
        end

        # Add volume to attributes
        #
        # @param val [String] the value
        def volume(val)
          attributes[:volume_number] = [val.to_s]
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
