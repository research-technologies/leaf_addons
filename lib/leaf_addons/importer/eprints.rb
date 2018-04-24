# frozen_string_literal: true

module LeafAddons
  module Importer
    module Eprints
      extend ActiveSupport::Autoload

      autoload :JsonDownloader
      autoload :JsonAttributes
    end
  end
end
