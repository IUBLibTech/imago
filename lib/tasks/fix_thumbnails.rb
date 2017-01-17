#
# Ruby process to rebuild thumbnails within a specific nunmerical range
#
# Created because some thumbnails were accidentally deleted
# Task is run with 'rake cbrc:fix_thumbnails:fix_thumbnails[start,end]
# start and end are numerical ranges for images catalog numbers (1002,1014) for example
#

module Cbrc

  module FixThumbnails

    module Tasks

      def Tasks.fix_thumbnails(startItem, endItem)
        x = startItem.to_i
        y = endItem.to_i
        while (x <= y)
          iter = 0
          catnum = "IND-"
          while (iter < (7 - x.to_s.length))
            catnum = catnum + "0"
            iter = iter + 1
          end
          catnum = catnum + x.to_s
          puts "Attempting to make thumbnail for " + catnum

          gfs = (Work.search_with_conditions catalog_number_sim: catnum).first['hasRelatedImage_ssim'].first
          file_set = FileSet.find(gfs)
          repository_file = file_set.send('original_file'.to_sym)
          working_file = CurationConcerns::WorkingDirectory.copy_repository_resource_to_working_directory(repository_file, file_set.id)
          filename = CurationConcerns::WorkingDirectory.find_or_retrieve(repository_file.id, file_set.id)
          file_set.create_derivatives(filename)
          
          x = x + 1
        end

      end
    end
  end
end
