module LeafAddons
  # rubocop:disable Metrics/ClassLength
  class CoversheetService
    attr_reader :object, :file_path, :work, :file_url, :citation_object
    attr_accessor :coversheet

    def initialize(object)
      @object = object
      if object.is_a?(FileSet)
        @work = object.parent
        @file_path = CoversheetDerivativePath.derivative_path_for_reference(object, 'service_file')
      end
      @citation_object = CitationService.new(work)
    end

    # Can this FileSet have a coversheet added?
    #  @return Boolean true if there is a service_file || the original file is a PDF
    def coversheetable?
      if file_path.nil?
        false
      elsif File.exist?(file_path)
        true
      elsif object.original_file.mime_type == 'application/pdf'
        @file_path = nil
        @file_url = object.original_file.uri
        true
      else
        false
      end
    end

    # Generate coversheet and attach to PDF
    def with_coversheet
      generate
      combine
    end

    def generate
      @coversheet = Prawn::Document.new(page_size: LeafAddons.config.coversheet_page_size,
                                        margin: LeafAddons.config.coversheet_margin)
      image
      coversheet.font LeafAddons.config.coversheet_font
      #Load a ttf file to match the font from the config (DB a ttf file with a matching name will need to be put in place)
      font_file=Rails.root.join('assets/fonts/'+LeafAddons.config.coversheet_font+'.ttf'
      Rails.logger.error("font file : #{font_file}")
      coversheet.font_families.update(LeafAddons.config.coversheet_font =>{:normal=>font_file)})
      coversheet.font_size LeafAddons.config.coversheet_fontsize_small
      LeafAddons.config.coversheet_blocks_in_order.each do |block|
        render(block, LeafAddons.config.coversheet_blocks[block]) if respond_to?(block)
      end
    end

    def combine
      pdf_path = CoversheetDerivativePath.derivative_path_for_reference(object, 'service_file').gsub('.pdf', '_withcover.pdf')
      pdf = CombinePDF.new
      pdf << CombinePDF.parse(coversheet.render)
      pdf << CombinePDF.load(file_path) unless file_path.nil?
      pdf << CombinePDF.parse(http_request(file_url)) unless file_url.blank?
      pdf.save pdf_path
      pdf_path
    end

    def http_request(uri)
      Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Get.new(uri.request_uri)
        req.basic_auth ActiveFedora.fedora_config.credentials[:user], ActiveFedora.fedora_config.credentials[:password]
        http.request req
      end.body
    end

    def logo
      LeafAddons.config.coversheet_image
    end

    def image
      return if logo.blank?
      coversheet.image logo, position: :center, width: 400
      coversheet.move_down LeafAddons.config.coversheet_spaces[:large]
    end

    def render(block_name, block_config)
      render_special(block_name, block_config) if block_config[:attribute].nil?
      render_block(block_name, block_config) unless block_config[:attribute].nil?
    end

    def render_block(block_name, block_config)
      return if work.send(block_config[:attribute]).first.blank?
      coversheet.text "#{label(block_name, block_config[:label])}#{work.send(block_config[:attribute]).join(block_config[:join])}".force_encoding('UTF-8')
      coversheet.move_down LeafAddons.config.coversheet_spaces[block_config[:space]]
    end

    def render_special(block_name, block_config)
      send(block_name, label(block_name, block_config[:label]))
      coversheet.move_down LeafAddons.config.coversheet_spaces[block_config[:space]]
    end

    def label(block_name, label_me)
      return '' if label_me.blank?
      l = "#{I18n.t('coversheet.' + block_name)}: "
      l = "<b>#{l}</b>" if LeafAddons.config.coversheet_labels_bold == true
      l = "<i>#{l}</i>" if LeafAddons.config.coversheet_labels_italic == true
      l
    end

    def author_title(label)
      coversheet.font_size LeafAddons.config.coversheet_fontsize_large
      coversheet.text "#{label}#{work.creator.join(',')}. <i>#{work.title.join(':')}.</i>", inline_format: true
      coversheet.font_size LeafAddons.config.coversheet_fontsize_small
    end

    def year(label)
      y = citation_object.citation.data.first[:issued]
      return unless y.is_a? CiteProc::Date
      return if y.empty?
      coversheet.text "#{label}#{y}", inline_format: true
      coversheet.move_down LeafAddons.config.coversheet_spaces[LeafAddons.config.coversheet_blocks['year'][:space]]
    end

    # can't guarantee order, so just take the first abstract
    def abstract(label)
      return if work.abstract.first.blank?
      coversheet.text label.to_s, inline_format: true
      coversheet.move_down LeafAddons.config.coversheet_spaces[:small]
      coversheet.indent LeafAddons.config.coversheet_indent, LeafAddons.config.coversheet_indent do
        coversheet.text work.abstract.first.to_s
      end
    end

    def url(label)
      url = "#{application_url}/downloads/#{object.id}"
      coversheet.text "#{label}<link href=\"#{url}\">[#{url}]</link>", align: :right, inline_format: true
    end

    def available_url(label)
      url = "#{application_url}/concern/#{work.class.to_s.underscore.pluralize}/#{work.id}"
      coversheet.text "#{label}<link href=\"#{url}\">#{url}</link>", inline_format: true
    end

    def publication_status(label)
      return if work.publication_status.first.blank?
      coversheet.text "#{label}#{work.publication_status.map do |l|
        AuthorityService::PublicationStatusesService.new.label(l)
      end.join(LeafAddons.config.coversheet_blocks['license'][:join])}", inline_format: true
    rescue
      work.publication_status.join(LeafAddons.config.coversheet_blocks['publication_status'][:join])
    end

    def license(label)
      return if work.license.first.blank?
      coversheet.text "#{label}<link href=\"#{work.license.first}\">#{Hyrax::LicenseService.new.label(work.license.first)}</link>", inline_format: true
    rescue
      work.license.join(LeafAddons.config.coversheet_blocks['license'][:join])
    end

    def type(label)
      if work.resource_type.first.blank?
        coversheet.text "#{label}#{work.class.to_s.underscore.titleize}"
      else
        coversheet.text "#{label}#{work.resource_type.join(',')}"
      end
    end

    def citation(label)
      coversheet.text label, inline_format: true
      coversheet.move_down LeafAddons.config.coversheet_spaces[:small]
      coversheet.indent LeafAddons.config.coversheet_indent, LeafAddons.config.coversheet_indent do
        coversheet.text citation_object.render.join('; '), inline_format: true
      end
    end

    # rubocop:disable Rails/TimeZone
    def submitted_date(label)
      d = DateTime.parse(work.date_uploaded.to_s)
      coversheet.text "#{label}#{d.to_date}", inline_format: true
    rescue ArgumentError => e
      Rails.logger.error(e)
    end
    # rubocop:enable Rails/TimeZone

    def copyright_statement(label)
      coversheet.text "#{label}#{I18n.t('coversheet.copyright_statement_text')}", valign: :bottom
    end

    def application_url
      "#{Rails.application.config.force_ssl ? 'https://' : 'http://'}#{ENV.fetch('APPLICATION_HOST', 'localhost')}"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
