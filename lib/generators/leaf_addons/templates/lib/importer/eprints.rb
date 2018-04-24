# frozen_string_literal: true

module Importer
  module Eprints
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :JsonImporter
      autoload :JsonParser
      autoload :JsonAttributesOverrides
    end
  end
end
