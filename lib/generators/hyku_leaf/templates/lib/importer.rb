module Importer
  extend ActiveSupport::Autoload
  eager_autoload do
  # autoload :AttachFiles # what is this?
    autoload :Eprints
    autoload :DirectoryFilesImporter
    autoload :FilesParser
    autoload :Factory
  end
end
