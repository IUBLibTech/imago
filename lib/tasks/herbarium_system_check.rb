#
# Ruby process for system checks
#

module Cbrc
  module SystemCheck
    module Tasks
      def Tasks.herbarium_system_check

        puts "IMAGES CURRENTLY IN IMAGO:"
        Work.find_each("#{Solrizer.solr_name('depositor', :symbol)}:\"jhallida@indiana.edu\"", fl: "id") do |id|
          gfs = (Work.search_with_conditions catalog_number_sim: id.catalog_number).first['hasRelatedImage_ssim'].first
          height = FileSet.find(gfs).height.first.to_i
          width = FileSet.find(gfs).width.first.to_i
          if height < width
            puts "THIS ONE HAS WRONG ALIGNMENT"
          end
          if (height < 2000) || (width < 2000)
            puts "THIS ONE IS TOO SMALL"
          end
          puts id.catalog_number
        end

      end
    end
  end
end
