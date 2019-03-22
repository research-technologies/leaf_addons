# frozen_string_literal: true

module LeafAddons
  class Configuration
    attr_writer :create_pdfs_on_ingest
    def create_pdfs_on_ingest
      @create_pdfs_on_ingest ||= true
    end

    attr_writer :citation_style
    def citation_style
      @citation_style ||= 'apa'
    end

    # rubocop:disable Metrics/MethodLength

    attr_writer :citation_mapping
    def citation_mapping
      @citation_mapping ||= {
        'author' => 'creator',
        'title' => 'title',
        'editor' => 'editor',
        'doi' => 'doi',
        'url' => 'official_url',
        'publisher' => 'publisher',
        'publisher_place' => 'place_of_publication',
        'issue' => 'issue_number',
        'volume' => 'volume_number',
        'page' => 'pagination',
        'event' => 'presented_at',
        'container_title' => 'part_of',
        'issued' => 'date_published',
        'event_date' => 'event_date'
      }
    end

    # Hash of blocks with configuration:
    #   key is the block name (String)
    #   value is a hash containing:
    #     attribute: work attribute to use to populate (omitted where method)
    #     label:  add a label in the coversheet, true|false (labels from locales)
    #     space: :small or :large (Symbol)
    #     join: what to use to join multiple values (omitted where method)
    attr_writer :coversheet_blocks
    def coversheet_blocks
      @coversheet_blocks ||= {
        'url' => { label: false, space: :large },
        'author_title' => { label: false, space: :large },
        'date_published' => { label: false, space: :small },
        'type' => { label: false, space: :small },
        'publication_status' => { label: true, space: :small, join: ', ' },
        'license' => { label: true, space: :small, join: ', ' },
        'abstract' => { label: true, space: :large },
        'citation' => { label: true, space: :large },
        'available_url' => { label: true, space: :small },
        'official_url' => { attribute: 'official_url', label: true, space: :small, join: ', ' },
        'doi' => { attribute: 'doi', label: true, space: :small, join: ', ' },
        'publisher' => { attribute: 'publisher', label: true, space: :small, join: ', ' },
        'submitted_date' => { label: true, space: :small },
        'copyright_statement' => { label: false, space: :small }
      }
    end

    # rubocop:enable Metrics/MethodLength

    attr_writer :coversheet_blocks_in_order
    def coversheet_blocks_in_order
      @coversheet_blocks_in_order ||= %w[url author_title type publication_status license abstract citation available_url official_url doi publisher submitted_date copyright_statement]
    end

    attr_writer :coversheet_image
    def coversheet_image
      @coversheet_image ||= open('https://via.placeholder.com/500x200/008000C/FFFFFFC/?text=change with LeafAddons.config.coversheet_image')
    end

    attr_writer :coversheet_spaces
    def coversheet_spaces
      @coversheet_spaces ||= { small: 10, large: 25 }
    end

    attr_writer :coversheet_font
    def coversheet_font
      @coversheet_font ||= 'Helvetica'
    end

    attr_writer :coversheet_fontsize_small
    def coversheet_fontsize_small
      @coversheet_fontsize_small ||= 10
    end

    attr_writer :coversheet_fontsize_large
    def coversheet_fontsize_large
      @coversheet_fontsize_large ||= 16
    end

    attr_writer :coversheet_indent
    def coversheet_indent
      @coversheet_indent ||= 20
    end

    attr_writer :coversheet_page_size
    def coversheet_page_size
      @coversheet_page_size ||= 'A4'
    end

    attr_writer :coversheet_margin
    def coversheet_margin
      @coversheet_margin ||= [50, 50]
    end
  end
end
