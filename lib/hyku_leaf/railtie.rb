# frozen_string_literal: true

require 'hyku_leaf'
require 'rails'
module HykuLeaf
  class Railtie < Rails::Railtie
    railtie_name :hyku_leaf

    rake_tasks do
      load "tasks/user_accounts.rake"
    end
  end
end
