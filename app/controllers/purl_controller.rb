# new class for imago to handle purl redirection
class PurlController < ApplicationController

  def render_404
    render :file => "/public/404.html",  :status => 404
  end

  def full
    begin
      realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['hasRelatedImage_ssim'].first
    rescue
      render_404 and return
    end

    redirect_to("#{request.protocol}#{request.host_with_port}/downloads/#{realid}")
  end

  def thumbnail
    begin
      realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['hasRelatedImage_ssim'].first
    rescue
      render_404 and return
    end

    redirect_to("#{request.protocol}#{request.host_with_port}/downloads/#{realid}?file=thumbnail")
  end

  def default
    begin
      #realid='4t64gn166'
      realid = (Work.search_with_conditions catalog_number_sim: params[:id]).first['id']
    rescue
      render_404 and return
    end

    redirect_to("#{request.protocol}#{request.host_with_port}/concern/works/#{realid}")
  end

end
