# frozen_string_literal: true

module Importer
  module Factory
    class PublishedWorkFactory < ObjectFactory
      include HykuLeaf::Importer::Factory::BaseFactoryBehaviour
      self.klass = PublishedWork
    end
  end
end
