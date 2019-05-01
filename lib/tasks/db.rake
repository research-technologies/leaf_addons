namespace :leaf_addons do
  namespace :db do
    desc 'Check the db exists'
    task setup_and_migrate: [:environment] do
      begin
        Rake::Task["db:migrate"].invoke if ActiveRecord::Base.connection_pool.with_connection(&:active?) && ActiveRecord::Migrator.needs_migration?
      rescue StandardError
        Rake::Task["db:setup"].invoke
      end
    end
  end
end
