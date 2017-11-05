module Importer
  module Eprints
    extend ActiveSupport::Autoload
    autoload :JsonImporter
    autoload :JsonParser
  end
end
