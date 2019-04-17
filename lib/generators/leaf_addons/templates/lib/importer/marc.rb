# frozen_string_literal: true

module Importer
  module Marc
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :MarcImporter
      autoload :MarcParser
      autoload :MarcAttributesOverrides
    end
  end
end
