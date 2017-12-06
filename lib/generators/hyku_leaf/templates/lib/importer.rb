# frozen_string_literal: true

module Importer
  extend ActiveSupport::Autoload
  eager_autoload do
    autoload :Eprints
    autoload :DirectoryFilesImporter
    autoload :FilesParser
    autoload :Factory
  end
end
