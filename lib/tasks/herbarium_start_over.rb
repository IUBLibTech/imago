#
# Ruby process for batch import of all Herbarium objects to a brand new repository, using PURLS to grab existing images
#
# Task is run with 'rake cbrc:herbarium_start_over:herbarium_start_over[filename.csv,email@example.com]
#

require 'net/smtp'

module Cbrc

  module HerbariumStartOver

    module Tasks

      def Tasks.herbarium_start_over(data_file, owner_username)
        print "------\n"
        print "INGESTING FROM PURLS..."
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
          begin
            open("http://purl.dlib.indiana.edu/iudl/herbarium/full/#{cat_num}") { |image_path|
              print "Found image for #{cat_num}\n"

              gfs = Work.search_with_conditions catalog_number_sim: cat_num
              if gfs.size != 0
                print "Existing record found for #{cat_num}. Skipping...\n"
                next
              end

              multivalue_row = row.to_hash.map do |k,v|
                v ||= ''
                if Work.properties[k].try :multiple?
                  [k, [v]]
                else
                  [k, v]
                end
              end

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

            }
          rescue
            print "Couldn't find image for #{cat_num}\n";
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
