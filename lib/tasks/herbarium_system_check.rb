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
        idsWrongAlignment = Array[]
        idsTooSmall = Array[]
        sdaAll = Array[]

        #read in SDA file
        puts "READING IN SDA FILE"
        File.readlines(Rails.root.join('public', 'sda_all.txt')).each do |line|
          sdaAll.push(line.strip)
        end

        #scan through images
        puts "STARING IMAGO IMAGE SCAN"
        x = 0;
        Work.find_each("#{Solrizer.solr_name('depositor', :symbol)}:\"herbaria@indiana.edu\"", fl: "id") do |id|
          x = x + 1
          if x % 100 == 0
            puts "Read #{x} objects"
          end
          gfs = (Work.search_with_conditions catalog_number_sim: id.catalog_number).first['hasRelatedImage_ssim'].first
          thefile = FileSet.find(gfs)
          height = thefile.height.first.to_i
          width = thefile.width.first.to_i
          #write to appropriate files based on imago status
          if height < width
            idsWrongAlignment.push(id.catalog_number.first.to_s)
          end
          if (height < 2000) || (width < 2000)
            idsTooSmall.push(id.catalog_number.first.to_s)
          end
          idsAll.push(id.catalog_number.first.to_s)
        end

        #sort arrays for output
        puts "SORTING ARRAYS..."
        idsAll.sort!
        idsWrongAlignment.sort!
        idsTooSmall.sort!

        #create difference arrays
        puts "CREATING DIFF ARRAYS..."
        imago_not_sda = idsAll - sdaAll
        sda_not_imago = sdaAll - idsAll

        puts ("GENERATING HTML AND TEXT FILES");
        #delete any existing system check files
        if Rails.root.join('public', 'herbariumcheck.html').exist?
          File.delete(Rails.root.join('public', 'herbariumcheck.html'))
        end
        if Rails.root.join('public', 'imago_all.txt').exist?
          File.delete(Rails.root.join('public', 'imago_all.txt'))
        end
        if Rails.root.join('public', 'imago_sideways.txt').exist?
          File.delete(Rails.root.join('public', 'imago_sideways.txt'))
        end
        if Rails.root.join('public', 'imago_toosmall.txt').exist?
          File.delete(Rails.root.join('public', 'imago_toosmall.txt'))
        end
        #create new system check files and open them for writing
        check_html = File.new(Rails.root.join('public', 'herbariumcheck.html'), 'w')
        imago_all = File.new(Rails.root.join('public', 'imago_all.txt'), 'w')
        imago_sideways = File.new(Rails.root.join('public', 'imago_sideways.txt'), 'w')
        imago_toosmall = File.new(Rails.root.join('public', 'imago_toosmall.txt'), 'w')
        file_imago_not_sda = File.new(Rails.root.join('public', 'imago_not_sda.txt'), 'w')
        file_sda_not_imago = File.new(Rails.root.join('public', 'sda_not_imago.txt'), 'w')

        #writing html file
        check_html.puts("<html><head><title>HERBARIUM SYSTEM CHECK</title></head><body>")
        check_html.puts("<h2>Imago Herbarium Imago System Check</h2>")
        check_html.puts("<p>Date of System Check: #{Time.now}</p>")
        check_html.puts("<p>SDA list was generated on: #{File.mtime(Rails.root.join('public', 'sda_all.txt'))}</p>")
        check_html.puts("<p><a href='imago_all.txt'>List all items in Imago</a> Total: #{idsAll.size}</p>")
        check_html.puts("<p><a href='imago_sideways.txt'>List all items in Imago that are sideways</a> Total: #{idsWrongAlignment.size}</p>")
        check_html.puts("<p><a href='imago_toosmall.txt'>List all items in Imago that are too small</a> Total: #{idsTooSmall.size}</p>")
        check_html.puts("<p><a href='sda_all.txt'>List all items in SDA</a> Total: #{sdaAll.size}</p>")
        check_html.puts("<p><a href='sda_not_imago.txt'>List all items in SDA not in Imago</a> Total: #{sda_not_imago.size}</p>")
        check_html.puts("<p><a href='imago_not_sda.txt'>List all items in Imago not SDA</a> Total: #{imago_not_sda.size}</p>")
        check_html.close

        #write list of all files
        idsAll.each do |id|
          imago_all.puts(id)
        end
        imago_all.close

        #write list of sideways files
        idsWrongAlignment.each do |id|
          imago_sideways.puts(id)
        end
        imago_sideways.close

        #write list of small files
        idsTooSmall.each do |id|
          imago_toosmall.puts(id)
        end
        imago_toosmall.close

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

      end
    end
  end
end
