# frozen_string_literal: true

class LeafAddons::InvitableGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator switches on and configures the devise-invitible gem.
      '

  def banner
    say_status("info", "Adding Devise Invitable", :blue)
  end

  def add_to_gemfile
    gem 'devise_invitable'
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def generate_install
    generate 'devise_invitable:install'
    generate 'devise_invitable User'
  end

  def switch_off_registerable
    inject_into_file 'app/models/user.rb', '# ', before: ':registerable' unless File.read('app/models/user.rb').include? '# :registerable'
  end

  def copy_files
    copy_file 'app/controllers/invitations_controller.rb', 'app/controllers/invitations_controller.rb'
  end

  def add_routes
    invites = ", :controllers => { :invitations => 'invitations' }"
    inject_into_file 'config/routes.rb', invites, after: "devise_for :users" unless File.read('config/routes.rb').include? invites
  end
end
