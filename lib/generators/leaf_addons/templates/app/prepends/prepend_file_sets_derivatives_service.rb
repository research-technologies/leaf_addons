# inserted by LeafAddons - Coversheet generator
# Prepend for Hyrax::FileSetDerivativesService

module PrependFileSetsDerivativesService
  # override method - create pdf service file for office docs
  def create_office_document_derivatives(filename)
    Hydra::Derivatives::DocumentDerivatives.create(
      filename,
      outputs: [{
        label: :thumbnail, format: 'jpg',
        size: '200x150>',
        url: derivative_url('thumbnail'),
        layer: 0
      },
                {
                  label: :service_file, format: 'pdf',
                  url: derivative_url('service_file')
                }]
    )
    extract_full_text(filename, uri)
  end

  # override method- change to using CoversheetDerivativePath
  def derivative_path_factory
    LeafAddons::CoversheetDerivativePath
  end
end
