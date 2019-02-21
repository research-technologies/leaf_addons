# frozen_string_literal: true

class LeafAddons::CoversheetGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator adds and enables coversheet generation.
This works for Hyku and Hyrax apps.
      '

  def banner
    say_status("info", "Adding Coversheets", :blue)
  end

  def add_gems
    gem 'prawn'
    gem 'combine_pdf'
    gem 'citeproc-ruby'
    gem 'csl-styles'
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def add_files
    copy_file 'app/prepends/prepend_downloads_controller.rb', 'app/prepends/prepend_downloads_controller.rb'
    copy_file 'app/prepends/prepend_file_sets_derivatives_service.rb', 'app/prepends/prepend_file_sets_derivatives_service.rb'
    copy_file 'app/prepends/prepend_document.rb', 'app/prepends/prepend_document.rb'
    copy_file 'config/initializers/coversheet_prepends.rb', 'config/initializers/coversheet_prepends.rb'
    copy_file 'config/initializers/coversheet_config.rb', 'config/initializers/coversheet_config.rb'
    copy_file 'config/locales/coversheet.en.yml', 'config/locales/coversheet.en.yml'
  end
end
