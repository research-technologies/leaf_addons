# inserted by LeafAddons - Coversheet generator
# Prepend for Hyrax::DownloadsController

module PrependDownloadsController
  attr_accessor :coversheet

  # Create coversheet file if file is coversheetable
  # new method
  def load_service_file
    @coversheet = LeafAddons::CoversheetService.new(asset)
    coversheet.with_coversheet if coversheet.coversheetable?
  rescue StandardError => e
    Rails.logger.error(e.message)
    return nil
  end

  # override method - retrieve the coversheeted file if available
  def load_file
    file_reference = params[:file]

    if file_reference.blank?
      file_path = load_service_file
      return default_file if file_path.blank?
#      return default_file if file_path == true
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
      custom_file_name || params[:filename] || (asset.respond_to?(:label) && asset.label.split('.').first + '.pdf')
    else
      params[:filename] || File.basename(file) || (asset.respond_to?(:label) && asset.label)
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  # override this to supply different download file_name
  def custom_file_name
    nil
  end
end
