namespace :db do
  desc "Migrate the database through scripts in db/migrations. Target specific version with VERSION=x."
  task :migrate do
    Sequel::Migrator.migrate(Sequel::Model.db, File.join(Jekyllku.lib_path, '../db/migrations', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
end
