# Implementation Notes

To use the importer in an application

inject into lib/importer.rb
    autoload :Eprints
    autoload :DirectoryFilesImporter
    autoload :FilesParser

create lib/importer/eprints.rb
create lib/importer/directory_files_importer.rb
create lib/importer/files_parser.rb

create lib/importer/eprints/json_importer.rb
create lib/importer/eprints/json_parser.rb

(optionally create other files in eprints if things need overriding)

inject into lib/importer/factory.rb
    autoload :MyModel (one for each model being imported)
    
create lib/factory/my_model.rb (one for each model being imported)


    
