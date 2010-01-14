require 'sequel/extensions/migration'

namespace :db do
  desc "Migrate the database."
  task :migrate => :environment do
    Sequel::Migrator.apply Sequel::Model.db, File.join(Jekyllku.lib_path, '../db/migrations')
  end
end
