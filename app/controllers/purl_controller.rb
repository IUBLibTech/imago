# new class for imago to handle purl redirection
class PurlController < ApplicationController

  def render_404
    render :file => "/public/404.html",  :status => 404
  end

  def full
    begin
      realid = ''
      if params[:id].start_with?("VAD8336")
        #paleo
        tempid = params[:id].slice(7..26);
        tempid = "IUPC" + tempid;
        filesets = (Work.search_with_conditions catalog_number_sim: tempid).first['file_set_ids_ssim']
        filesets.each do |fileset|
          filesettitle = FileSet.find(fileset).title.first
          if filesettitle.start_with?(params[:id])
            realid = FileSet.find(fileset).id
            break
          end
        end
      else
        # assume herbarium
        realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['hasRelatedImage_ssim'].first
      end
      if (realid == '')
        raise "Realid isn't valid"
      end
    rescue
      render_404 and return
    end
    redirect_to("#{request.protocol}#{request.host_with_port}/downloads/#{realid}")
  end

  def thumbnail
    begin
      realid = ''
      if params[:id].start_with?("VAD8336")
        #paleo
        tempid = params[:id].slice(7..26);
        tempid = "IUPC" + tempid;
        filesets = (Work.search_with_conditions catalog_number_sim: tempid).first['file_set_ids_ssim']
        filesets.each do |fileset|
          filesettitle = FileSet.find(fileset).title.first
          if filesettitle.start_with?(params[:id])
            realid = FileSet.find(fileset).id
            break
          end
        end
      else
        # assume herbarium
        realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['hasRelatedImage_ssim'].first
      end
      if (realid == '')
        raise "Realid isn't valid"
      end
    rescue
      render_404 and return
    end
    redirect_to("#{request.protocol}#{request.host_with_port}/downloads/#{realid}?file=thumbnail")
  end

  def default
    begin
      if params[:id].start_with?("VAD8336")
        #paleo
        tempid = params[:id].slice(7..-1);
        tempid = "IUPC" + tempid;
        realid = (Work.search_with_conditions catalog_number_sim: tempid).first['id']
      else
          # assume herbarium
          realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['id']
      end
    rescue
      render_404 and return
    end

    redirect_to("#{request.protocol}#{request.host_with_port}/concern/works/#{realid}")
  end

end
