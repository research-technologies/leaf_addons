# frozen_string_literal: true

class LeafAddons::ImportersGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator adds eprints_json and directory_of_files importers into the application.
This works for Hyku and Hyrax apps.
      '

  def banner
    say_status("info", "Adding the Importers", :blue)
  end

  def create_importers
    if File.exist?('lib/importer.rb')
      importer = 'lib/importer.rb'
      injection = "\n  autoload :Eprints"
      injection += "\n  autoload :DirectoryFilesImporter"
      injection += "\n  autoload :Factory\n"
      injection += "\n  autoload :FilesParser\n"
      injection += "\n  autoload :Marc"

      unless File.read(importer).include? injection
        inject_into_file importer, after: "extend ActiveSupport::Autoload" do
          injection
        end
      end
    else
      copy_file 'lib/importer.rb', 'lib/importer.rb'
    end
    directory 'lib/importer', 'lib/importer'
  end

  def create_factories
    if File.exist? 'lib/importer/factory.rb'
      factory = 'lib/importer/factory.rb'
      injection = "    \nautoload :BaseFactory"
      injection += "    \nautoload :PublishedWorkFactory"
      injection += "    \nautoload :ConferenceItemFactory\n"
      injection += "    \nautoload :JournalArcticleFactory\n"
      injection += "    \nautoload :Dataset\n"

      unless File.read(factory).include? 'PublishedWorkFactory'
        inject_into_file factory, after: "eager_autoload do\n" do
          injection
        end
      end
    else
      copy_file 'lib/importer/factory.rb', 'lib/importer/factory.rb'
    end
    directory 'lib/importer/factory/', 'lib/importer/factory/'
  end

  def create_bin_files
    directory 'bin', 'bin'
    bin_one = 'bin/import_files_to_existing_objects'
    bin_two = 'bin/import_from_eprints_json'
    bin_three = 'bin/import_from_marc'

    # If we aren't in a Hyku app, remove the AccountElevator code
    if File.exist?('config/initializers/version.rb')
      unless File.read('config/initializers/version.rb').include? 'Hyku'
        gsub_file bin_one, /AccountElevator.switch/, "# AccountElevator.switch"
        gsub_file bin_two, /AccountElevator.switch/, "# AccountElevator.switch"
        gsub_file bin_three, /AccountElevator.switch/, "# AccountElevator.switch"
      end
    else
      gsub_file bin_one, /AccountElevator.switch/, "# AccountElevator.switch"
      gsub_file bin_two, /AccountElevator.switch/, "# AccountElevator.switch"
      gsub_file bin_three, /AccountElevator.switch/, "# AccountElevator.switch"
    end

    run 'chmod +x bin/import_files_to_existing_objects'
    run 'chmod +x bin/import_from_eprints_json'
    run 'chmod +x bin/import_from_marc'
  end
end
