#
# Ruby process for batch import to Paleo collection, called by rake tasks
#
# This is used to import a batch for the Paleo collection, using an associated CSV file
# Task is run with 'rake cbrc:paleo_batch_import:paleo_batch_import[filename.csv,email@example.com,"NO"]
# Images should be in same directory as CSV file
# Files will be deleted after ingest only if deleteafteringest is set to "YES"
#

require 'net/smtp'

module Cbrc

  module PaleoBatchImport

    module Tasks

      def Tasks.paleo_batch_import(data_file, owner_username, deleteafteringest)
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

        # create an empty Set to keep track of whether we've seen this catalog number before
        # since there can be multiple items per catalog number
        allnums = [].to_set

        # go through and ingest each line of the file
        CSV.foreach(data_file, headers:true) do |row|
          cat_num = row['IMAGO:catalogNumber'].to_s
          #files are named a bit differently than cat num
          cat_num_file = cat_num.clone
          cat_num_file.slice!(0..3)
          cat_num_file.prepend("VAD8336")

          if (allnums.include?(cat_num))
            next
          end
          allnums.add(cat_num)
          #search for matching files in the directory
          thefiles = Dir.glob("#{data_dir}/#{cat_num_file}*-full.jpg")
          thefiles.sort!
          if (thefiles.empty?)
            #nothing to do here
            next
          end
          #thefiles array of files is now ready for ingesting
          #next, prep metadata
          multivalue_row = []
          row.to_hash.map do |k,v|
            v ||= ''
            if k == "IMAGO:catalogNumber"
              k = 'catalog_number'
            end
            if k == "dwc:basisOfRecord"
              k = "basis_of_record"
            end
            if k == "dwc:class"
              k = "dwcclass"
            end
            if k == "dwc:specificEpithet"
              k = "specific_epithet"
            end
            if k == "dwc:scientificName"
              k = "scientific_name"
            end
            if k == "dwc:scientificNameAuthorship"
              k = "scientific_name_authorship"
            end
            if k == "dwc:stateProvince"
              k = "state_province"
            end
            if k == "dwc:otherCatalogNumbers"
              k = "other_catalog_numbers"
            end
            if k == "dwc:member"
              k = "dwcmember"
            end
            if k == "dwc:latestAgeOrHighestStage"
              k = "latest_age_or_highest_stage"
            end
            if k == "dwc:earliestAgeOrLowestStage"
              k = "earliest_age_or_lowest_stage"
            end
            if k == "dwc:latestPeriodOrHighestSystem"
              k = "latest_period_or_highest_system"
            end
            if k == "dwc:earliestPeriodOrLowestSystem"
              k = "earliest_period_or_lowest_system"
            end
            if k == "dwc:typeStatus"
              k = "type_status"
            end
			if k == "dwc:kingdom"
              k = "kingdom"
            end
			if k == "dwc:phylum"
              k = "phylum"
            end
			if k == "dwc:order"
              k = "order"
            end
			if k == "dwc:family"
              k = "family"
            end
			if k == "dwc:genus"
              k = "genus"
            end
			if k == "dwc:country"
              k = "country"
            end
			if k == "dwc:county"
              k = "county"
            end
			if k == "dwc:locality"
              k = "locality"
            end
			if k == "dwc:bed"
              k = "bed"
            end
			if k == "dwc:formation"
              k = "formation"
            end
			if k == "dwc:group"
              k = "group"
            end

            if (k != "catalog_number") && (k != "kingdom") && (k != "basis_of_record") && (k != "phylum") \
                    && (k != "order") && (k != "family") && (k != "dwcclass") && (k != "genus") && (k != "specific_epithet") \
                    && (k != "scientific_name") && (k != "scientific_name_authorship") \
                    && (k != "country") && (k != "state_province") && (k != "county") && (k != "locality") \
                    && (k != "other_catalog_numbers") \
                    && (k != "bed") && (k != "dwcmember") && (k != "formation") && (k != "group") \
                    && (k != "latest_age_or_highest_stage") && (k != "earliest_age_or_lowest_stage") \
                    && (k != "latest_period_or_highest_system") && (k != "earliest_period_or_lowest_system") && (k != "type_status")
              next
            end
            if Work.properties[k].try :multiple?
              multivalue_row.push([k, [v]])
            else
              multivalue_row.push([k, v])
            end
          end
          puts "Ingesting #{cat_num}"
          the_work = Work.search_with_conditions catalog_number_sim: cat_num
          if the_work.size == 0
            gf = Work.create!(multivalue_row.to_h) do |obj|
              #add a few more boilerplate metadata items
              obj.title = [cat_num]
              obj.depositor = owner.email
              obj.edit_users = [owner.email]
              obj.rights = ['http://creativecommons.org/licenses/by-nc/3.0/us/']
              obj.collection_code = ['paleontology']
              obj.identifier = ["http://purl.dlib.indiana.edu/iudl/paleontology/#{cat_num_file}"]
              obj.set_read_groups( ["public"], [])
            end
            #add all files that we found
            thefiles.each do |singlefile|
              puts "Adding image #{singlefile}"
              file_set = ::FileSet.new
              file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, owner)
              file_set_actor.create_metadata(gf, visibility: gf.visibility)
              file_set_actor.create_content(File.open(singlefile))
              if deleteafteringest == "YES"
                File.delete(singlefile)
              end
            end
          else
            #TODO IMPLEMENT THIS CORRECTLY
            puts "UPDATING PALEO COLLECTION THROUGH BATCH NOT YET SUPPORTED"
            next
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

          next

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
