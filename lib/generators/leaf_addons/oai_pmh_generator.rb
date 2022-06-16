# frozen_string_literal: true

class LeafAddons::OaiPmhGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc '
This generator switches on and configures the blacklight_oai_provider gem.
      '

  def banner
    say_status("info", "Adding blacklight_oai_provider", :blue)
  end

 # def add_to_gemfile
 #   gem 'oai'
 #   gem 'blacklight_oai_provider', '~> 6'
 #   Bundler.with_unbundled_env do
 #     run "bundle install"
 #   end
 # end

  def generate_install
    generate 'blacklight_oai_provider:install'
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/LineLength

  def update_solr_document
    solr_doc = '  BlacklightOaiProvider::SolrDocument'
    inject_into_file 'app/models/solr_document.rb', "#{solr_doc}\n", after: "include Blacklight::Solr::Document\n" unless File.read('app/models/solr_document.rb').include? solr_doc

    field_semantics = %(  
   field_semantics.merge!(
      contributor: 'contributor_tesim',
      creator: 'creator_tesim',
      date: 'date_created_tesim',
      description: 'description_tesim',
      identifier: 'identifier_tesim',
      language: 'language_tesim',
      publisher: 'publisher_tesim',
      relation: 'nesting_collection__pathnames_ssim',
      rights: 'rights_statement_tesim',
      subject: 'subject_tesim',
      title: 'title_tesim',
      type: 'human_readable_type_tesim'
    ))
    inject_into_file 'app/models/solr_document.rb', "#{field_semantics}\n", before: "\nend" unless File.read('app/models/solr_document.rb').include? 'field_semantics.merge!'
  end

  def update_catalog_controller
    controller = '  include BlacklightOaiProvider::Controller'
    inject_into_file 'app/controllers/catalog_controller.rb', "#{controller}\n", after: "include Hydra::Controller::ControllerBehavior\n" unless File.read('app/controllers/catalog_controller.rb').include? controller

    config = %(
    config.oai = {
      provider: {
        repository_name: ENV.fetch('OAI_REPO_NAME', 'Hyrax'),
        repository_url: ENV.fetch('OAI_REPO_URL', 'http://localhost:3000/catalog/oai'),
        record_prefix: ENV.fetch('OAI_PREFIX', 'oai:hyrax'),
        admin_email: ENV.fetch('OAI_ADMIN_EMAIL', 'change_me@example.com'),
        sample_id: ENV.fetch('OAI_SAMPLE_ID', 'dj52w4688'),
      },
      document: {
        limit: 25, # number of records returned with each request, default: 15
        set_fields: [ # ability to define ListSets, optional, default: nil
          { label: 'collection', solr_field: 'isPartOf_ssim' },
          { label: 'type', solr_field: 'has_model_ssim' }
        ]
      }
    }
    )
    inject_into_file 'app/controllers/catalog_controller.rb', "#{config}\n", after: "config.spell_max = 5\n" unless File.read('app/controllers/catalog_controller.rb').include? config
  end

  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/LineLength

  def add_routes
    concern = 'concern :oai_provider, BlacklightOaiProvider::Routes.new'
    inject_into_file 'config/routes.rb', "#{concern}\n", after: "Rails.application.routes.draw do\n" unless File.read('config/routes.rb').include? concern

    concerns = 'concerns :oai_provider'
    inject_into_file 'config/routes.rb', "#{concerns}\n", after: "controller: 'catalog' do\n" unless File.read('config/routes.rb').include? concerns
  end
end
