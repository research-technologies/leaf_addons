# inserted by LeafAddons - Coversheet generator
Rails.application.config.to_prepare do
  Hyrax::DownloadsController.prepend ::PrependDownloadsController

  if LeafAddons.config.create_pdfs_on_ingest == true
    Hyrax::FileSetDerivativesService.prepend ::PrependFileSetsDerivativesService
    Hydra::Derivatives::Processors::Document.prepend ::PrependDocument

    # soffice can fail/hang on convert to pdf, set timeout to 60 seconds
    Hydra::Derivatives::DocumentDerivatives.processor_class.timeout = 60
  end
end
