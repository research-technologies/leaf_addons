module LeafAddons
  class CitationService
    attr_accessor :citation, :object_id, :citation_item

    # Build citation for given work
    #
    # @param object [ActiveFedora::Base] work (not file_set)
    # @param format [String] default is html, text is also valid
    def initialize(object, format = 'html')
      return if object.is_a?(FileSet)
      return unless format == 'html' || format == 'text'
      @citation = CiteProc::Processor.new style: LeafAddons.config.citation_style, format: format
      build_citation_item(object)
    end

    def render(type = :bibliography)
      return '' if citation.nil?
      citation.render type, id: object_id
    end

    protected

      def build_citation_item(object)
        @object_id = object.id
        @citation_item = CiteProc::Item.new(id: object_id)
        citation_item_values(object)
        citation_type
        citation.import citation_item
      end

      def citation_item_values(object)
        LeafAddons.config.citation_mapping.each_key do |key|
          if object.respond_to?(LeafAddons.config.citation_mapping[key]) && (key == 'issued' || key == 'event_date')
            citation_item.send("#{key}=", 'literal' => object.send(LeafAddons.config.citation_mapping[key]).first)
          elsif object.respond_to?(LeafAddons.config.citation_mapping[key])
            citation_item.send("#{key}=", object.send(LeafAddons.config.citation_mapping[key]).first)
          end
        end
      end

      def citation_type
        citation_item.type = if citation_item.event.present? || citation_item.event_date.present?
                               'paper-conference'
                             elsif citation_item.container_title.present? && citation_item.volume.present?
                               'article-journal'
                             elsif citation_item.container_title.present?
                               'chapter'
                             else
                               'book'
                             end
      end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
