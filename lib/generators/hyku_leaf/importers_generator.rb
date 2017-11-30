# frozen_string_literal: true

class HykuLeaf::ImportersGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator adds eprints_json and directory_of_files importers into the application.
This works for Hyku and Hyrax apps.
      '

  def banner
    say_status("info", "Adding the Importers", :blue)
  end

  # what about factories?
  def create_importers
    if File.exist?('lib/importer.rb')
      importer_text = File.read('lib/importer.rb')
      importer = 'lib/importer.rb'
      injection = "\n  autoload :Eprints"
      injection += "\n  autoload :DirectoryFilesImporter"
      injection += "\n  autoload :Factory\n"
      injection += "\n  autoload :FilesParser\n"

      unless importer_text.include? injection
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
      factory_text = File.read('lib/importer/factory.rb')
      factory = 'lib/importer/factory.rb'
      injection = "    \nautoload :PublishedWorkFactory"
      injection += "    \nautoload :ConferenceItemFactory\n"
      unless factory_text.include? 'PublishedWorkFactory'
        inject_into_file factory, after: "eager_autoload do\n" do
          injection
        end
      end
    else
      copy_file 'lib/importer/factory.rb', 'lib/importer/factory.rb'
    end
    copy_file 'lib/importer/factory/conference_item_factory.rb', 'lib/importer/factory/conference_item_factory.rb'
    copy_file 'lib/importer/factory/published_work_factory.rb', 'lib/importer/factory/published_work_factory.rb'
  end
  
  def create_bin_files
    bin_one = 'bin/import_files_to_existing_objects'
    bin_two = 'bin/import_from_eprints_json'

    copy_file bin_one, bin_one
    copy_file bin_two, bin_two

    # If we aren't in a Hyku app, remove the AccountElevator code
    if File.exist?('config/initializers/version.rb')
      unless File.read('config/initializers/version.rb').include? 'Hyku'
        gsub_file bin_one, /AccountElevator.switch/, "# AccountElevator.switch"
        gsub_file bin_two, /AccountElevator.switch/, "# AccountElevator.switch"
      end
    else
      gsub_file bin_one, /AccountElevator.switch/, "# AccountElevator.switch"
      gsub_file bin_two, /AccountElevator.switch/, "# AccountElevator.switch"
    end

    run 'chmod +x bin/import_files_to_existing_objects'
    run 'chmod +x bin/import_from_eprints_json'
  end

  # These exist in Hyku, but not in Hyrax. If these don't exist, download them.
  def download_files
    unless File.exist?('lib/importer/factory/object_factory.rb')
      run "wget https://raw.githubusercontent.com/samvera-labs/hyku/master/lib/importer/factory/object_factory.rb -O lib/importer/factory/object_factory.rb"
    end
    unless File.exist?('lib/importer/factory/string_literal_processor.rb')
      run "wget https://raw.githubusercontent.com/samvera-labs/hyku/master/lib/importer/factory/string_literal_processor.rb -O lib/importer/factory/string_literal_processor.rb"
    end
    unless File.exist?('lib/importer/log_subscriber.rb')
      run "wget https://raw.githubusercontent.com/samvera-labs/hyku/master/lib/importer/log_subscriber.rb -O lib/importer/log_subscriber.rb"
    end
  end
end
