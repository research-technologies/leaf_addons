module Importer
  module Factory
    class PublishedWorkFactory < ObjectFactory
      include HykuLeaf::BaseFactoryBehaviour
      self.klass = PublishedWork
    end
  end
end