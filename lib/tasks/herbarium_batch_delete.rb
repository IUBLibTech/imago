#
# Ruby process for batch deletion, called by rake tasks
#
# This is used to delete a batch of records. Needed because we had to delete records for endagered species
# Task is run with 'rake cbrc:herbarium_batch_delete:herbarium_batch_delete[filename.csv]
# filename.csv is a list of files to delete, one per line, with 'catalog_number' as a header for the CSV file
#

module Cbrc

  module HerbariumBatchDelete

    module Tasks

      def Tasks.herbarium_batch_delete(data_file)
        print "------\n";
        print "Delete batch file started at " + Time.now.utc.iso8601 + "\n";
        print "------\n";
        data_dir = File.dirname data_file
        unless File.exists?(data_dir)
          print "ERROR: Can't find the data directory\n"
          exit
        end
        # go through and delete each line of the file
        CSV.foreach(data_file, headers:true) do |row|
          cat_num = row['catalog_number'].to_s
          gfs = Work.search_with_conditions catalog_number_sim: cat_num
          multivalue_row = row.to_hash.map do |k,v|
            v ||= ''
            if Work.properties[k].try :multiple?
              [k, [v]]
            else
              [k, v]
            end
          end

          if gfs.size == 1
            Work.find(gfs[0].id).destroy
          else
            print "WARNING: Item #{cat_num} was not found.\n"
          end
        end
        print "------\n";
        print "Delete complete\n";
        print "------\n";
      end

    end
  end
end
