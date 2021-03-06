namespace :cbrc do

  require "#{Rails.root}/lib/tasks/herbarium_batch_import"
  require "#{Rails.root}/lib/tasks/herbarium_batch_import_extras"

  require "#{Rails.root}/lib/tasks/hunt_batch_import"
  require "#{Rails.root}/lib/tasks/iuse_batch_import"

  require "#{Rails.root}/lib/tasks/herbarium_start_over"
  require "#{Rails.root}/lib/tasks/paleo_batch_import"
  require "#{Rails.root}/lib/tasks/paleo_batch_update"
  require "#{Rails.root}/lib/tasks/herbarium_batch_update"
  require "#{Rails.root}/lib/tasks/herbarium_batch_delete"
  require "#{Rails.root}/lib/tasks/herbarium_system_check"
  require "#{Rails.root}/lib/tasks/paleo_system_check"
  require "#{Rails.root}/lib/tasks/herbarium_fix_thumbnails"

  namespace :herbarium_batch_import do
    desc "Import Herbarium records from CSV."
    task :herbarium_batch_import, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::HerbariumBatchImport::Tasks::herbarium_batch_import(args.datafile, args.owner, args.deleteafteringest)
    end
  end

  namespace :herbarium_batch_import_extras do
    desc "Import Herbarium records from CSV (extra content)."
    task :herbarium_batch_import_extras, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::HerbariumBatchImportExtras::Tasks::herbarium_batch_import_extras(args.datafile, args.owner, args.deleteafteringest)
    end
  end

  namespace :hunt_batch_import do
    desc "Import Herbarium records from CSV from Huntington."
    task :hunt_batch_import, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::HuntBatchImport::Tasks::hunt_batch_import(args.datafile, args.owner, args.deleteafteringest)
    end
  end

  namespace :iuse_batch_import do
    desc "Import Herbarium records from CSV from IU Southeast."
    task :iuse_batch_import, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::IuseBatchImport::Tasks::iuse_batch_import(args.datafile, args.owner, args.deleteafteringest)
    end
  end

  namespace :herbarium_batch_import do
    desc "Import Herbarium records from CSV."
    task :herbarium_batch_import, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::HerbariumBatchImport::Tasks::herbarium_batch_import(args.datafile, args.owner, args.deleteafteringest)
    end
  end

  namespace :herbarium_batch_update do
    desc "Update Herbarium records from CSV."
    task :herbarium_batch_update, [:datafile, :owner] => :environment do |task, args|
      Cbrc::HerbariumBatchUpdate::Tasks::herbarium_batch_update(args.datafile, args.owner)
    end
  end
  namespace :herbarium_start_over do
    desc "Import Herbarium records from CSV and grab PURL images from existing repo."
    task :herbarium_start_over, [:datafile, :owner] => :environment do |task, args|
      Cbrc::HerbariumStartOver::Tasks::herbarium_start_over(args.datafile, args.owner)
    end
  end
  namespace :paleo_batch_import do
    desc "Import Paleo records from CSV."
    task :paleo_batch_import, [:datafile, :owner, :deleteafteringest] => :environment do |task, args|
      Cbrc::PaleoBatchImport::Tasks::paleo_batch_import(args.datafile, args.owner, args.deleteafteringest)
    end
  end
  namespace :paleo_batch_update do
    desc "Update Paleo records from CSV."
    task :paleo_batch_update, [:datafile, :owner] => :environment do |task, args|
      Cbrc::PaleoBatchUpdate::Tasks::paleo_batch_update(args.datafile, args.owner)
    end
  end
  namespace :herbarium_batch_delete do
    desc "Delete Herbarium records from CSV."
    task :herbarium_batch_delete, [:datafile] => :environment do |task, args|
      Cbrc::HerbariumBatchDelete::Tasks::herbarium_batch_delete(args.datafile)
    end
  end
  namespace :system_check do
    desc "Run system maintenance tasks for herbarium."
    task :herbarium_system_check, [:datafile] => :environment do |task, args|
      Cbrc::SystemCheck::Tasks::herbarium_system_check
    end
  end
  namespace :system_check do
    desc "Run system maintenance tasks for paleo."
    task :paleo_system_check, [:datafile] => :environment do |task, args|
      Cbrc::SystemCheck::Tasks::paleo_system_check
    end
  end
  namespace :herbarium_fix_thumbnails do
    desc "Fix missing thumbnails for a range of records in the Herbarium collection."
    task :herbarium_fix_thumbnails, [:startItem, :endItem] => :environment do |task, args|
      Cbrc::HerbariumFixThumbnails::Tasks::herbarium_fix_thumbnails(args.startItem, args.endItem)
    end
  end

end