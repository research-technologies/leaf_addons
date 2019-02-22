# inserted by LeafAddons - Coversheet generator
# Prepend for Hyrax::DownloadsController

module PrependDownloadsController
  # Create coversheet file if file is coversheetable
  # new method
  def load_service_file
    c = LeafAddons::CoversheetService.new(asset)
    c.with_coversheet if c.coversheetable?
  end

  # override method - retrieve the coversheeted file if available
  def load_file
    file_reference = params[:file]

    if file_reference.blank?
      file_path = load_service_file
      return default_file if file_path.blank?
    else
      file_path = Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
    end

    File.exist?(file_path) ? file_path : nil
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable PerceivedComplexity

  # override method
  def local_file_name
    if File.basename(file).include? 'service_file'
      params[:filename] || (asset.respond_to?(:label) && asset.label.split('.').first + '.pdf')
    else
      params[:filename] || File.basename(file) || (asset.respond_to?(:label) && asset.label)
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable PerceivedComplexity
end
