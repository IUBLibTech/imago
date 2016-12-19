namespace :cbrc do
  require "#{Rails.root}/lib/tasks/batch_import"
  require "#{Rails.root}/lib/tasks/batch_delete"
  require "#{Rails.root}/lib/tasks/herbarium_system_check"
  namespace :import do
    desc "Import Herbarium records from CSV."
    task :import_herbs, [:datafile, :owner] => :environment do |task, args|
      Cbrc::Ingest::Tasks::import_herbs(args.datafile, args.owner)
    end
  end
  namespace :delete do
    desc "Delete Herbarium records from CSV."
    task :delete_herbs, [:datafile] => :environment do |task, args|
      Cbrc::Delete::Tasks::delete_herbs(args.datafile)
    end
  end
  namespace :system_check do
    desc "Run system maintenance tasks."
    task :herbarium_system_check, [:datafile] => :environment do |task, args|
      Cbrc::SystemCheck::Tasks::herbarium_system_check
    end
  end
end