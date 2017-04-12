#
# Ruby process for batch update of metadata to Herbarium collection. Given a spreadsheet, this will
# update any existing items with the metadata. It will not create new records, nor will it
# touch any existing images.
#
# Task is run with 'rake cbrc:herbarium_batch_update:herbarium_batch_update[filename.csv,email@example.com]
#

require 'net/smtp'

module Cbrc

  module HerbariumBatchUpdate

    module Tasks

      def Tasks.herbarium_batch_update(data_file, owner_username)
        print "------\n"
        print "Bach update file started at " + Time.now.utc.iso8601 + "\n"
        emailbody = "Batch update file started at " + Time.now.utc.iso8601 + "\n"
        print "------\n"
        owner = User.find_by_user_key(owner_username)
        if owner.nil?
          print "ERROR: User to run update not found\n"
          emailbody = emailbody + "ERROR: User to run update not found\n"
          exit
        end

        # go through and update for each line of the file
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

          if gfs.size == 0
            print "Ignoring #{cat_num} because no matching record was found.\n"
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

            if gf.save
              print "Updated #{cat_num}.\n"
              emailbody = emailbody + "Updated #{cat_num}.\n"
            else
              print "WARNING: Update failed: #{gf.errors.full_messages}\n"
              emailbody = emailbody + "WARNING: Update failed: #{gf.errors.full_messages}\n"
            end
          end
        end
        print "------\n"
        print "Update complete\n"
        emailbody = emailbody + "Update complete\n"
        print "------\n"

        #send an email
        msg = <<END_OF_MESSAGE
From: FROMEMAIL
To: TOEMAIL
Subject: Imago Update Complete

        #{emailbody}

END_OF_MESSAGE

        Net::SMTP.start("127.0.0.1") do |smtp|
          smtp.send_message msg, "fromemail", "toemail"
        end

      end
    end
  end
end
