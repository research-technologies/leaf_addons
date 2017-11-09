# frozen_string_literal: true

module HykuLeaf
  extend ActiveSupport::Autoload
  require 'hyku_leaf/railtie' if defined?(Rails)

  eager_autoload do
    autoload :Importer
  end
end
