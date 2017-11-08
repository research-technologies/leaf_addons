module HykuLeaf
  module Importer
    module Factory
      module BaseFactoryBehaviour

        # Override
        def transform_attributes
          attributes.slice(*permitted_attributes).merge(file_attributes)
        end

        # Override ObjectFactory to add remote files and uploaded files into the attributes
        #
        # @return hash of remote_files and/or uploaded_files
        def file_attributes
          hash = {}
          hash[:remote_files] = attributes[:remote_files] unless attributes[:remote_files].blank?
          hash[:uploaded_files] = attributes[:uploaded_files] unless attributes[:uploaded_files].blank?
          hash
        end
      end
    end
  end
end
