# frozen_string_literal: true

module HykuLeaf
  extend ActiveSupport::Autoload
  require 'hyku_leaf/railtie' if defined?(Rails)
end