#
# Ruby process for batch import, called by rake tasks
#
# This is used to import a batch of files from the Herbarium, along with an associated CSV file
# Task is run with 'rake cbrc:import:import_herbs[filename.csv,email@example.com,"NO"]
#

require 'net/smtp'

module Cbrc

  module Ingest

    module Tasks

      # rake cbrc:import:import_herbs[{CSV path},{user email}]
      # Images are in same directory as CSV file, filename format "{catalog_number}-full.jpg"
      # Files will be deleted after ingest only if deleteafteringest is set to "YES"
      def Tasks.import_herbs(data_file, owner_username, deleteafteringest)
        print "------\n"
        print "Ingest batch file started at " + Time.now.utc.iso8601 + "\n"
        emailbody = "Ingest batch file started at " + Time.now.utc.iso8601 + "\n"
        print "------\n"
        data_dir = File.dirname data_file
        unless File.exists?(data_dir)
          print "ERROR: Can't find the data directory\n"
          emailbody = emailbody + "ERROR: Can't find the data directory\n"
          exit
        end
        owner = User.find_by_user_key(owner_username)
        if owner.nil?
          print "ERROR: User to run ingest not found\n"
          emailbody = emailbody + "ERROR: User to run ingest not found\n"
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
            emailbody = emailbody + "Image found for #{cat_num}.\n"
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
            if deleteafteringest == "YES"
              File.delete(image_path)
            end

          else
            print "Existing record found for #{cat_num}.\n"
            emailbody = emailbody + "Existing record found for #{cat_num}.\n"
            gf = Work.find(gfs.first['id'])
            gf.update(multivalue_row.to_h)

            gf.title = [cat_num]
            gf.depositor = owner.email
            gf.edit_users = [owner.email]
            gf.rights = ['http://creativecommons.org/licenses/by-nc/3.0/us/']
            gf.collection_code = ['herbarium']
            gf.identifier = ["http://purl.dlib.indiana.edu/iudl/herbarium/#{cat_num}"]
            gf.set_read_groups( ["public"], [])

            #delete old image (assumes only 1)
            FileSet.find((Work.search_with_conditions id: gf.id).first['hasRelatedImage_ssim'].first).destroy

            #add new image
            file_set = ::FileSet.new
            file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, owner)
            file_set_actor.create_metadata(gf, visibility: gf.visibility)
            file_set_actor.create_content(File.open(image_path))

            if gf.save
              print "Updated #{cat_num}.\n"
              emailbody = emailbody + "Updated #{cat_num}.\n"
            else
              print "WARNING: Update failed: #{gf.errors.full_messages}\n"
              emailbody = emailbody + "WARNING: Update failed: #{gf.errors.full_messages}\n"
            end
            if deleteafteringest == "YES"
              File.delete(image_path)
            end
          end
        end
        print "------\n"
        print "Ingest complete\n"
        emailbody = emailbody + "Ingest complete\n"
        print "------\n"

        #send an email
        msg = <<END_OF_MESSAGE
From: FROMEMAIL
To: TOEMAIL
Subject: Imago Ingest Complete

        #{emailbody}

END_OF_MESSAGE

        Net::SMTP.start("127.0.0.1") do |smtp|
          smtp.send_message msg, "fromemail", "toemail"
        end

      end
    end
  end
end
