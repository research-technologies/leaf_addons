module Importer
  module Factory
    class ConferenceItemFactory < ObjectFactory
      include HykuLeaf::BaseFactoryBehaviour

      self.klass = ConferenceItem

    end
  end
end