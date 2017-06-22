#
# Ruby process for system checks
#

module Cbrc
  module SystemCheck
    module Tasks
      def Tasks.herbarium_system_check

        puts "RUNNING HERBARIUM SYSTEM CHECK"

        #initialize arrays
        idsAll = Array[]
        sdaAll = Array[]
#        etrAll = Array[]
        symbiotaAll = Array[]

        #read in SDA file
        puts "READING IN SDA FILE"
        File.readlines(Rails.root.join('public', 'sda_all.txt')).each do |line|
          sdaAll.push(line.strip)
        end

        #read in ETR file
#        puts "READING IN ETR FILE"
#        File.readlines(Rails.root.join('public', 'etr_all.txt')).each do |line|
#          etrAll.push(line.strip)
#        end

        #read in Symbiota file
        puts "READING IN SYMBIOTA FILE"
        File.readlines(Rails.root.join('public', 'symbiota_all.txt')).each do |line|
          symbiotaAll.push(line.strip)
        end

        #scan through images
        puts "STARING IMAGO IMAGE SCAN"
        x = 0
	ids = []
        Work.search_in_batches("#{Solrizer.solr_name('depositor', :symbol)}:\"herbaria@indiana.edu\"", fl: "catalog_number_tesim") do |group|
          idsAll.concat group.map { |doc| doc["catalog_number_tesim"].first }
	  x = x + 1000
	  puts "Read #{x}"
        end

        #sort array for output
        puts "SORTING ARRAYS..."
        idsAll.sort!

        #create difference arrays
        puts "CREATING DIFF ARRAYS..."
        imago_not_sda = idsAll - sdaAll
        sda_not_imago = sdaAll - idsAll
        symbiota_not_sda = symbiotaAll - sdaAll
 #       etr_and_imago = etrAll & idsAll

        puts ("GENERATING HTML AND TEXT FILES");
        #delete any existing system check files
        if Rails.root.join('public', 'herbariumcheck.html').exist?
          File.delete(Rails.root.join('public', 'herbariumcheck.html'))
        end
        if Rails.root.join('public', 'imago_all.txt').exist?
          File.delete(Rails.root.join('public', 'imago_all.txt'))
        end
        if Rails.root.join('public', 'symbiota_not_sda.txt').exist?
          File.delete(Rails.root.join('public', 'symbiota_not_sda.txt'))
        end
  #      if Rails.root.join('public', 'etr_and_imago.txt').exist?
  #        File.delete(Rails.root.join('public', 'etr_and_imago.txt'))
  #      end
        #create new system check files and open them for writing
        check_html = File.new(Rails.root.join('public', 'herbariumcheck.html'), 'w')
        imago_all = File.new(Rails.root.join('public', 'imago_all.txt'), 'w')
        file_imago_not_sda = File.new(Rails.root.join('public', 'imago_not_sda.txt'), 'w')
        file_sda_not_imago = File.new(Rails.root.join('public', 'sda_not_imago.txt'), 'w')
        file_symbiota_not_sda = File.new(Rails.root.join('public', 'symbiota_not_sda.txt'), 'w')
#        file_etr_and_imago = File.new(Rails.root.join('public', 'etr_and_imago.txt'), 'w')

        #writing html file
        check_html.puts("<html><head><title>HERBARIUM SYSTEM CHECK</title></head><body>")
        check_html.puts("<h2>Imago Herbarium Imago System Check</h2>")
        check_html.puts("<p>Date of System Check: #{Time.now}</p>")
        check_html.puts("<p>SDA list was generated on: #{File.mtime(Rails.root.join('public', 'sda_all.txt'))}</p>")
        check_html.puts("<p>Symbiota list was generated on: #{File.mtime(Rails.root.join('public', 'symbiota_all.txt'))}</p>")
 #       check_html.puts("<p>ETR list was generated on: #{File.mtime(Rails.root.join('public', 'etr_all.txt'))}</p>")
        check_html.puts("<p><a href='imago_all.txt'>List all items in Imago</a> Total: #{idsAll.size}</p>")
        check_html.puts("<p><a href='sda_all.txt'>List all items in SDA</a> Total: #{sdaAll.size}</p>")
        check_html.puts("<p><a href='sda_not_imago.txt'>List all items in SDA not in Imago (excluding ETR)</a> Total: #{sda_not_imago.size}</p>")
        check_html.puts("<p><a href='imago_not_sda.txt'>List all items in Imago not SDA</a> Total: #{imago_not_sda.size}</p>")
        check_html.puts("<p><a href='symbiota_all.txt'>List all items in Symbiota</a> Total: #{symbiotaAll.size}</p>")
        check_html.puts("<p><a href='symbiota_not_sda.txt'>List all items in Symbiota NOT in SDA</a> Total: #{symbiota_not_sda.size}</p>")
  #      check_html.puts("<p><a href='etr_all.txt'>List all items on ETR list</a> Total: #{etrAll.size}</p>")
  #      check_html.puts("<p><a href='etr_and_imago.txt'>List all items on ETR list that are in Imago</a> Total: #{etr_and_imago.size}</p>")
        check_html.close

        #write list of all files
        idsAll.each do |id|
          imago_all.puts(id)
        end
        imago_all.close

        #files in Imago but not SDA
        imago_not_sda.each do |id|
          file_imago_not_sda.puts(id)
        end
        file_imago_not_sda.close

        #file in SDA but not Imago
        sda_not_imago.each do |id|
          file_sda_not_imago.puts(id)
        end
        file_sda_not_imago.close

        #file in Symbiota but not SDA
        symbiota_not_sda.each do |id|
          file_symbiota_not_sda.puts(id)
        end
        file_symbiota_not_sda.close

        #file in ETR and also Imago
   #     etr_and_imago.each do |id|
   #       file_etr_and_imago.puts(id)
   #     end
   #     file_etr_and_imago.close

      end
    end
  end
end
