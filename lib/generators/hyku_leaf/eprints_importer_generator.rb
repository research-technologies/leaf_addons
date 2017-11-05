# frozen_string_literal: true

class DogBiscuits::EprintsImporterGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator ...
      '

  def banner
    say_status("info", "Adding the EPrints JSON Importer", :blue)
  end

  def create_importers

  end

  def autoload_importers

  end
end
