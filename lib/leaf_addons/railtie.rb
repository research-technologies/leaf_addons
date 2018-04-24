# frozen_string_literal: true

require 'leaf_addons'
require 'rails'
module LeafAddons
  class Railtie < Rails::Railtie
    railtie_name :leaf_addons

    rake_tasks do
      load 'tasks/user_accounts.rake'
    end
  end
end
