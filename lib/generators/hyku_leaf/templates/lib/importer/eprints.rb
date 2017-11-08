module Importer
  module Eprints
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :JsonImporter
      autoload :JsonParser
    end
  end
end
