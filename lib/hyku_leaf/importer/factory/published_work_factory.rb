module Importer
  module Factory
    class PublishedWorkFactory < ObjectFactory
      self.klass = PublishedWork
      # A way to identify objects that are not Hydra minted identifiers
      self.system_identifier_field = :identifier

      # TODO: add resource type?
      # def create_attributes
      #   #super.merge(resource_type: 'Image')
      # end

      # Override
      def transform_attributes
        attributes.slice(*permitted_attributes).merge(file_attributes)
      end

      # Override ObjectFactory to add remote files and uploaded files into the attributes
      #
      # @return hash of remote_files and/or uploaded_files
      def file_attributes
        hash = {}
        hash[:remote_files] = attributes[:remote_files] unless attributes[:remote_files].nil?
        hash[:uploaded_files] = attributes[:uploaded_files] unless attributes[:uploaded_files].nil?
        hash
      end
    end
  end
end
