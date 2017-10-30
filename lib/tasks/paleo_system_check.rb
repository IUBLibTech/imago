#
# Ruby process for system checks
#

module Cbrc
  module SystemCheck
    module Tasks
      def Tasks.paleo_system_check

        puts "RUNNING PALEO SYSTEM CHECK"

        #initialize arrays
        idsAll = Array[]
        sdaAll = Array[]
        symbiotaAll = Array[]

        #read in SDA file
        puts "READING IN SDA FILE"
        File.readlines(Rails.root.join('public', 'sda_all_paleo.txt')).each do |line|
          sdaAll.push(line.strip)
        end

        #read in Symbiota file
        puts "READING IN SYMBIOTA FILE"
        File.readlines(Rails.root.join('public', 'symbiota_all_paleo.txt')).each do |line|
          s=line.strip
          s=s.split('/')[-1]
          symbiotaAll.push(s)
        end

        #scan through images
        puts "STARING IMAGO IMAGE SCAN"
        x = 0
	ids = []
        FileSet.search_in_batches("#{Solrizer.solr_name('depositor', :symbol)}:\"palcoll@indiana.edu\"", fl: "title_tesim") do |group|
          idsAll.concat group.map { |doc| doc["title_tesim"].first.chomp("-full.jpg") }
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

        puts ("GENERATING HTML AND TEXT FILES");
        #delete any existing system check files
        if Rails.root.join('public', 'paleocheck.html').exist?
          File.delete(Rails.root.join('public', 'paleocheck.html'))
        end
        if Rails.root.join('public', 'imago_all.txt').exist?
          File.delete(Rails.root.join('public', 'imago_all.txt'))
        end
        if Rails.root.join('public', 'symbiota_not_sda.txt').exist?
          File.delete(Rails.root.join('public', 'symbiota_not_sda.txt'))
        end
        if Rails.root.join('public', 'symbiota_all_paleo_real.txt').exist?
          File.delete(Rails.root.join('public', 'symbiota_all_paleo_real.txt'))
        end
        #create new system check files and open them for writing
        check_html = File.new(Rails.root.join('public', 'paleocheck.html'), 'w')
        imago_all = File.new(Rails.root.join('public', 'imago_all_paleo.txt'), 'w')
        file_imago_not_sda = File.new(Rails.root.join('public', 'imago_not_sda_paleo.txt'), 'w')
        file_sda_not_imago = File.new(Rails.root.join('public', 'sda_not_imago_paleo.txt'), 'w')
        file_symbiota_not_sda = File.new(Rails.root.join('public', 'symbiota_not_sda_paleo.txt'), 'w')
        file_symbiota = File.new(Rails.root.join('public', 'symbiota_all_paleo_real.txt'), 'w')

        #writing html file
        check_html.puts("<html><head><title>PALEO SYSTEM CHECK</title></head><body>")
        check_html.puts("<h2>Imago Paleo Imago System Check</h2>")
        check_html.puts("<p>Date of System Check: #{Time.now}</p>")
        check_html.puts("<p>SDA list was generated on: #{File.mtime(Rails.root.join('public', 'sda_all_paleo.txt'))}</p>")
        check_html.puts("<p>Symbiota list was generated on: #{File.mtime(Rails.root.join('public', 'symbiota_all_paleo.txt'))}</p>")
        check_html.puts("<p><a href='imago_all_paleo.txt'>List all items in Imago</a> Total: #{idsAll.size}</p>")
        check_html.puts("<p><a href='sda_all_paleo.txt'>List all items in SDA</a> Total: #{sdaAll.size}</p>")
        check_html.puts("<p><a href='sda_not_imago_paleo.txt'>List all items in SDA not in Imago</a> Total: #{sda_not_imago.size}</p>")
        check_html.puts("<p><a href='imago_not_sda_paleo.txt'>List all items in Imago not SDA</a> Total: #{imago_not_sda.size}</p>")
        check_html.puts("<p><a href='symbiota_all_paleo_real.txt'>List all items in Symbiota</a> Total: #{symbiotaAll.size}</p>")
        check_html.puts("<p><a href='symbiota_not_sda_paleo.txt'>List all items in Symbiota NOT in SDA</a> Total: #{symbiota_not_sda.size}</p>")
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

        #file in Symbiota
        symbiotaAll.each do |id|
          file_symbiota.puts(id)
        end
        file_symbiota.close

      end
    end
  end
end
