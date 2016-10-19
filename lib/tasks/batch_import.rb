#
# Ruby process for batch import, called by rake tasks
#
# This is used to import a batch of files from the Herbarium, along with an associated CSV file
# Task is run with 'rake cbrc:import:import_herbs[filename.csv,email@indiana.edu]
#

module Cbrc

  module Ingest

    module Tasks
      # rake cbrc:import:import_herbs[{CSV path},{user email}]
      # Images are in same directory as CSV file, filename format "{catalog_number}-full.jpg"
      def Tasks.import_herbs(data_file, owner_username)
        print "------\n";
        print "Ingest batch file started at " + Time.now.utc.iso8601 + "\n";
        print "------\n";
        data_dir = File.dirname data_file
        unless File.exists?(data_dir)
          print "ERROR: Can't find the data directory\n"
          exit
        end
        owner = User.find_by_user_key(owner_username)
        if owner.nil?
          print "ERROR: User to run ingest not found\n"
          exit
        end

        # go through and ingest each line of the file
        CSV.foreach(data_file, headers:true) do |row|
          cat_num = row['catalog_number'].to_s
          # first check to make sure image exists for this line
          image_filename = "#{cat_num}-full.jpg"
          image_path = "#{data_dir}/#{image_filename}"
          if File.file?(image_path)
            print "Image found for #{cat_num}.\n"
          else
            print "WARNING: Could not import image for #{cat_num}. Not importing this object\n"
            next
          end

          gfs = Work.search_with_conditions catalog_number_sim: cat_num

          multivalue_row = row.to_hash.map do |k,v|
            v ||= ''
            if Work.properties[k].try :multiple?
              [k, [v]]
            else
              [k, v]
            end
          end

          #
          #if gfs.size > 1
          #  print "WARNING: Multiple results found for catalog number #{cat_num}. Only the first will be updated.\n"
          #end

          if gfs.size == 0

            gf = Work.create!(multivalue_row.to_h) do |obj|
              #add a few more boilerplate metadata items
              obj.title = [cat_num]
              obj.depositor = owner.email
              obj.edit_users = [owner.email]
              obj.rights = ['http://creativecommons.org/licenses/by-nc/3.0/us/']
              obj.collection_code = ['herbarium']
              obj.identifier = ["http://purl.dlib.indiana.edu/iudl/herbarium/#{cat_num}"]
              obj.set_read_groups( ["public"], [])
            end

            file_set = ::FileSet.new
            file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, owner)
            file_set_actor.create_metadata(gf, visibility: gf.visibility)
            file_set_actor.create_content(File.open(image_path))
            #characterize_and_derive(gf) ---> don't think this is necessary anymore


          else
            #for now, we won't process if file already exists - will not currently update images anyway
            print "WARNING: Item #{cat_num} alreadu exists. Not importing again.\n"
            #print "Existing record found for #{cat_num}.\n"
            ### (gf.attributes.to_a.sort & mod.sort) - m.sort
            #gf = GenericFile.find(gfs.first['id'])
            #gf.update(multivalue_row.to_h)
            # TODO Update file data when updating metadata.
            #if gf.save
            #  print "Updated metadata for #{cat_num}.\n"
            #else
            #  print "WARNING: Update failed: #{gf.errors.full_messages}\n"
            #end
            #characterize_and_derive(gf)
          end
        end
        print "------\n";
        print "Ingest complete\n";
        print "------\n";
      end

      private

      def Tasks.characterize_and_derive(gf)
        print "Characterizing..."
        if gf.characterize
          print "Success!\n"
        else
          print "WARNING: Failed to characterize.\n"
        end

        print "Deriving..."
        gf.create_derivatives
        if gf.save
          print "Success!\n"
        else
          print "WARNING: Failed to derive.\n"
        end
      end

    end
  end
end
