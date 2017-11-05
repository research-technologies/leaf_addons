module HykuLeaf
  module Importer
    module Eprints
      extend ActiveSupport::Autoload
      autoload :JsonAnalyser
      autoload :JsonImporter
      autoload :JsonParser
      autoload :JsonDownloader
      autoload :JsonMapper
    end
  end
end
