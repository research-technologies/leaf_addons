# frozen_string_literal: true

module Importer
  module Eprints
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :JsonImporter
      autoload :JsonParser
      autoload :JsonMapperOverrides
    end
  end
end
