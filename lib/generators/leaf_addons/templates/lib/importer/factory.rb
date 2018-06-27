# frozen_string_literal: true

module Importer
  module Factory
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :ObjectFactory
      autoload :StringLiteralProcessor
      autoload :ConferenceItemFactory
      autoload :DataSetFactory
      autoload :GenericWorkFactory
      autoload :JournalArticleFactory
      autoload :PublishedWorkFactory
      autoload :ThesisFactory
      autoload :BaseFactory
    end

    # @param [#to_s] First (Xxx) portion of an "XxxFactory" constant
    def self.for(model_name)
      const_get "#{model_name}Factory"
    end
  end
end
