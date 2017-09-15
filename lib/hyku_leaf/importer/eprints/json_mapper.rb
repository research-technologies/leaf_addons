module Importer
  module Eprints
    module JsonMapper

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
          'event_title'
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
          { date_published: val.to_s }
        else
          { date: val.to_s }
        end
      end

      # TODO create 'event' and add lookup
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

      # TODO create 'organisation' and lookup
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

      # TODO create 'person' and lookup
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

      # TODO create 'person' and lookup
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

      # TODO create 'organisation' and lookup
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

      # Add documents to attributes;
      #   :files_hash will be used for further processing outside of the object factory
      #   :remote_files will be used by the Object Factory to download the file from the supplied URL
      #
      # @param val [Hash] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def documents(val, attributes)
        files_hash = {}
        remote_files = []
        tmp_files_hash = build_tmp_files_hash(val)
        val.each do |doc|
          if doc['relation'].blank?
            files_hash[doc['main']] ||= {}
            files_hash[doc['main']][:visibility] = 'restricted' unless doc['security'] == 'public'
            uri = doc['uri'].split('/')
            remote_files << {
              file_name: doc['main'],
              url: "#{uri[0]}//#{uri[2]}/#{doc['eprintid']}/#{doc['pos']}/#{doc['main']}"
            }
          else
            files_hash = add_relation(doc, tmp_files_hash, files_hash)
          end
        end
        attributes[:files_hash] = files_hash
        attributes[:remote_files] = remote_files
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

      # TODO #KFSPECIFIC create KF_ID
	  # TODO stop using custom id here, knock on elsewhere though
      # Add eprintid to attributes
      #
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def eprintid(val, attributes)
        identifier = "ep#{val}"
        # Pad out the identifier to 9 chars to match noid structure
        identifier.sub!('ep', 'ep0') while identifier.length < 9
        attributes[:former_id] = [val.to_s]
		# attributes[:biblionumber] = [val.to_s]
        attributes[:id] = identifier
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

      # TODO lookup?
      # Add ispublished to attributes
      #
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def ispublished(val, attributes)
        # TODO: lookup
        attributes[:pulication_status] = val
        attributes
      end

      # Add keywords to attributes
      # cuments
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def keywords(val, attributes)
        attributes[:keyword] = val.split(',').collect(&:strip)
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
        attributes[:issue_number] = val.to_s
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
        attributes[:pagination] = val.to_s
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

      # TODO add Geonames service, blocked by https://github.com/samvera/hyrax/issues/1065
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
        # TODO: lookup
        if attributes[:resource_type].blank?
          attributes[:resource_type] = [val]
        else
          attributes[:resource_type] << val
        end
        attributes
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
                                  true
                                else
                                  false
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

      # TODO lookup?
      # Add subjects to attributes
      #
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def subjects(val, attributes)
        attributes[:subject] = [val.to_s]
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

      # TODO: lookup
      # Add type to attributes
      #
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def type(val, attributes)
        if attributes[:resource_type].blank?
          attributes[:resource_type] = [val]
        else
          attributes[:resource_type] << val
        end
        attributes
      end

      # Add volume to attributes
      #
      # @param val [String] the value
      # @param attributes [Hash] hash of attributes to update
      # @return [Hash] attributes
      def volume(val, attributes)
        attributes[:volume_number] = val.to_s
        attributes
      end

      private

        # Create a name string from parts
        #
        # @param name [Hash] name parts
        # @return [Hash] name string
        def make_name(name)
          "#{name['name']['family']}, #{name['name']['given']}"
        end

        def build_tmp_files_hash(val)
          tmp_files_hash = {}
          val.collect { |id| tmp_files_hash[id['docid'].to_s] = id['main'] }
          tmp_files_hash
        end

        # Add relations to the files_hash
        #
        # @param doc [Hash] the documents hash
        # @param tmp_files_hash [Hash] the temporary files_hash
        # @param files [Hash] the final files hash
        # @return [Hash] updated hash of files
        def add_relation(doc, tmp_files_hash, files)
          version_types ||= doc['relation'].collect { |t| t['type'].gsub('http://eprints.org/relation/', '') }
          if version_types.include?('isIndexCodesVersionOf')
            files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]][:additional_files] ||= []
            uri = doc['uri'].split('/')
            files[
                tmp_files_hash[doc['relation'][0]['uri'].split('/').last]][:additional_files] <<
              { file_name: doc['main'],
                url: "#{uri[0]}//#{uri[2]}/#{doc['eprintid']}/#{doc['pos']}/#{doc['main']}",
                type: 'extracted_text' }
            # Don't add thumbnails; they get generated by the characterization
            # elsif version_types.include?('issmallThumbnailVersionOf')
            #   files[tmp_files_hash[doc['relation'][0]['uri'].split('/').last]][:additional_files] ||= []
            #   files[
            #     tmp_files_hash[doc['relation'][0]['uri'].split('/').last]][:additional_files] <<
            #     { filename: doc['main'], type: 'thumbnail' }
          end
          files
        end
    end
  end
end
