module Importer
  module Eprints
    extend ActiveSupport::Autoload
    autoload :JsonAnalyser
    autoload :JsonImporter
    autoload :JsonParser
    autoload :JsonDownloader
    autoload :JsonMapper
    autoload :JsonFilesProcessor
  end
end
