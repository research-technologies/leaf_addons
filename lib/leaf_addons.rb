# frozen_string_literal: true

module LeafAddons
  extend ActiveSupport::Autoload
  require 'leaf_addons/railtie' if defined?(Rails)

  eager_autoload do
    autoload :Configuration
  end

  eager_autoload do
    autoload :Importer
  end

  autoload_under 'citation' do
    autoload :CitationService
  end

  autoload_under 'coversheet' do
    autoload :CoversheetDerivativePath
    autoload :CoversheetService
  end

  #
  # Exposes the LeafAddons configuration
  #
  # @yield [LeafAddons::Configuration] if a block is passed
  # @return [LeafAddons::Configuration]
  # @see LeafAddons::Configuration for configuration options
  def self.config(&block)
    @config ||= LeafAddons::Configuration.new

    yield @config if block

    @config
  end
end
