# inserted by LeafAddons - Coversheet generator
LeafAddons.config do |config|
  # Mapping from the citeproc-ruby (on the left) to local work attributes
  #   local work attributes must exist
  # config.citation_mapping = {
  #   'author' => 'creator',
  #   'title' => 'title',
  #   'editor' => 'editor',
  #   'doi' => 'doi',
  #   'url' => 'official_url',
  #   'publisher' => 'publisher',
  #   'publisher_place' => 'place_of_publication',
  #   'issue' => 'issue_number',
  #   'volume' => 'volume_number',
  #   'page' => 'pagination',
  #   'event' => 'presented_at',
  #   'container_title' => 'part_of',
  #   'issued' => 'date_published',
  #   'event_date' => 'event_date'
  # }

  # Citation style, see a full list with CSL::Style.ls
  # config.citation_style = 'apa'

  # Coversheet blocks to written onto the coversheet
  # Available blocks are defined in #available_blocks
  #  Various configurations are available:
  #    attribute: draw directly from a work attribute; omit where a special method should be used
  #    label: true or false, true to prepend a label before the value on the coversheet; labels are defined in config/locales/coversheet.en.yml
  #    space: supply the symbol defined in #coversheet_spaces (defaults are small: large:)
  #    join: if there are multiple values, how should they be joined (omit where this is not relevant)
  # config.coversheet_blocks = {
  #   'url' => { label: false, space: :large },
  #   'author_title' => { label: false, space: :large },
  #   'type' => { label: false, space: :small },
  #   'publication_status' => { attribute: 'publication_status', label: true, space: :small, join: ', ' },
  #   'license' => { label: true, space: :small, join: ', ' },
  #   'abstract' => { attribute: 'abstract', label: false, space: :large, join: "\n\n" },
  #   'citation' => { label: true, space: :large },
  #   'available_url' => { label: true, space: :small },
  #   'official_url' => { attribute: 'official_url', label: true, space: :small, join: ', ' },
  #   'doi' => { attribute: 'doi', label: true, space: :small, join: ', ' },
  #   'publisher' => { attribute: 'publisher', label: true, space: :small, join: ', ' },
  #   'submitted_date' => { label: true, space: :small },
  #   'copyright_statement' => { label: false, space: :small }
  # }

  # Defines the order of blocks, remove blocks from this list that are not wanted
  #   to add new block methods (eg. with prepend), add them in here too
  # config.coversheet_blocks_in_order = %w[url author_title type publication_status license abstract citation available_url official_url doi publisher submitted_date copyright_statement]

  # Set the banner image to an image location
  #   to use a URL, wrap it in open('http://the_url')
  # config.coversheet_image = ''

  # Add or change the spacing used in the coversheet
  # config.coversheet_spaces = { small: 10, large: 25 }

  # Configure the font, eg. 'Courier', 'Times-Roman' and 'Helvetica'
  # The font must be available to prawn
  # @see https://www.rubydoc.info/github/sandal/prawn/Prawn%2FDocument:font_families
  # default is Helvetica
  # config.coversheet_font = ''

  # Configure the smaller fontsize
  # config.coversheet_fontsize_small = 10

  # Configure the larger fontsize
  # config.coversheet_fontsize_large = 16

  # Configure the indent size
  # config.coversheet_indent = 20

  # Configure the margins, supply one or more values
  #  [50] set all to 50
  #  [50,100] set left and right to 50, top and bottom to 100
  #  [10, 20, 30, 40] top is 10, right is 20, bottom is 30, left is 40.
  # config.coversheet_margin = [50, 50]

  # Set the pagesize, default is A4
  # config.coversheet_page_size = 'A4'

  # Should PDF service files be created for office documents on ingest
  # If true PDFs with coversheets will be downloaded for these files
  # config.create_pdfs_on_ingest = true
end
