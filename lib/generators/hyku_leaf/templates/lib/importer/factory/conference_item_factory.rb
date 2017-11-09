# frozen_string_literal: true

module Importer
  module Factory
    class ConferenceItemFactory < ObjectFactory
      include HykuLeaf::Importer::Factory::BaseFactoryBehaviour

      self.klass = ConferenceItem
    end
  end
end
