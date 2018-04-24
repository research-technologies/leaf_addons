# frozen_string_literal: true

module LeafAddons
  extend ActiveSupport::Autoload
  require 'leaf_addons/railtie' if defined?(Rails)

  eager_autoload do
    autoload :Importer
  end
end
