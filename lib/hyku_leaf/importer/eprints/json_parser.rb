module Importer
  module Eprints
    class JsonParser
      include Enumerable
      include Eprints::JsonMapper

      def initialize(file_name)
        @file_name = file_name
      end

      # @yieldparam attributes [Hash] the attributes from one eprint
      def each(&_block)
        JSON.parse(File.read(@file_name)).each do |eprint|
          yield(attributes(eprint))
        end
      end

      private

        # Build the attributes for passing to Fedora

        # @param eprint [Hash] json for a single eprint
        # @return [Hash] attributes
        def attributes(eprint)
          attributes = standard_attributes(eprint)
          attributes = special_attributes(eprint, attributes)
          attributes[:model] = find_model(eprint['type'])
          attributes
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
              $stderr.puts "\nNo method exists for field #{k}"
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
          attributes.merge!(event_title(eprint['event_title'], eprint['event_type']))
          attributes.merge!(date(eprint['date'], eprint['date_type']))
          attributes.merge!(access_setting(eprint['metadata_visibility'], eprint['eprint_status']))
          attributes
        end

        # Determine the model for each eprint['type']
        #
        # @param [String] the eprint type value
        # @return [String] the Model name
        def find_model(type)
          case type
          when 'kfpub'
            'PublishedWork'
          when 'monograph'
            'PublishedWork'
          when 'book'
            'PublishedWork'
          else
            type.camelize
          end
        end
    end
  end
end
