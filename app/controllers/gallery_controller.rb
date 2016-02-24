class GalleryController < ApplicationController
  def index
    begin
      redirect_to gallery_side_path(params.except(:project).delete_if { |k,v| v.blank? }) if params[:site].present?
      @projects = Project.where(public_gallery: true)
      @project = params[:project] ? Project.find(params[:project]) : @projects.first
      @sites = @project.sites.order_by(:name => 'asc') rescue []
      @site = @project.sites.find(params[:site]) rescue nil

      filter_gallery   

    rescue => e
      Rails.logger.info "=============================================="
      Rails.logger.info "Somethings went wrong in RailsAdminSiteView"
      Rails.logger.info e
      Rails.logger.info "=============================================="
    ensure

    end
  end

  def show
    @projects = Project.where(public_gallery: true)
    @site = Site.find(params[:site]) rescue nil
    
    redirect_to gallery_path if @site.nil?
    
    @project = @site.project rescue nil
    @sites = @project.sites.order_by(:name => 'asc') rescue []
      
    filter_gallery
    render :index
    rescue => e
      Rails.logger.info "=============================================="
      Rails.logger.info "Somethings went wrong in RailsAdminSiteView"
      Rails.logger.info e
      Rails.logger.info "=============================================="
  end

  def get_project_sites
    if params[:project_id]
      @project = Project.where(id: params[:project_id]).first
      @sites = @project.sites.order_by(:name => 'asc') rescue []
      render json: {status: 200, sites: @sites}
    else
      render json: { status: 400 }
    end
  end

  def self.convertDateInput(str_date)
    DateTime.parse(str_date).to_time.to_i
  end

  def self.convertDatePhoto(photo)
    DateTime.parse(photo.created_at.to_s).to_s.scan(/\d+-\d+-\d+/).join("").to_time.to_i
  end

  def self.getPhotoYear(photos)
    years = []
    photos.each do |photo|
      year = DateTime.parse(photo.created_at.to_s).to_s.scan(/(\d+)-\d+-\d+/).join("").to_s
      years << year
    end
    return years.uniq
  end

  def self.getClosetDate(photos, date_input, direction)

    closet_photo = nil
    filter_list = photos.select{|photo| RailsAdminSiteView.convertDatePhoto(photo) <= RailsAdminSiteView.convertDateInput(date_input) }

    if filter_list.present?
      closet_photos = []
      if direction == "All"
        ["North","South","West","East"].each do |item|
          closet_photo = filter_list[0]
          filter_list.each do |photo|
            if RailsAdminSiteView.convertDatePhoto(photo) >= RailsAdminSiteView.convertDatePhoto(closet_photo) && photo.direction == item
              closet_photo = photo
            end
          end
          closet_photos << closet_photo
        end
      else
        closet_photo = filter_list[0]
        filter_list.each do |photo|
          if RailsAdminSiteView.convertDatePhoto(photo) >= RailsAdminSiteView.convertDatePhoto(closet_photo) && photo.direction == direction
            closet_photo = photo
          end
        end
        closet_photos << closet_photo
      end
    end
    return closet_photos
  end

  private

  def filter_gallery
    #@embed_map = '<iframe frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://narvis.maps.arcgis.com/apps/Embed/index.html?webmap=95921da6135b4d569c1befed59bb6dac&amp;extent=&amp;home=false&amp;zoom=false&amp;scale=false&amp;search=false&amp;details=false&amp;legend=false&amp;active_panel=details&amp;theme=light" style="width:100%; height: 400px;"></iframe>'
    @embed_map = '<iframe style="border: 0px currentColor;" src="https://www.google.com/maps/embed/v1/view?key=AIzaSyBnFAsgxTOTMujhi98Mt5PzAza3aHfr_NQ&center=-30.7378069,116.8034088&zoom=6&maptype=satellite" width="100%" height="400" frameborder="0"></iframe>'

    if @project.present? 
      if @site.present?
        @gallery_site_title = @site.name
        @photos = @site.photos.order_by(:created_at => 'asc')           
        
        if @site.gallery_html.present?
          @embed_map = @site.gallery_html 
        elsif @project.default_gallery_html.present?
          @embed_map = @project.default_gallery_html
        end
        
      end
    end
    direction = params[:direction]
    from_date = params[:from_date]
    to_date = params[:to_date]
    yearly_comparison = params[:yearly_comparison]

    if direction.present?
      @photos = @photos.select {|photo| direction == photo.direction}
    end

    if from_date.present? && to_date.present?
      @photos = @photos.select {|photo| RailsAdminSiteView.convertDateInput(from_date) <= RailsAdminSiteView.convertDatePhoto(photo) && RailsAdminSiteView.convertDateInput(to_date) >= RailsAdminSiteView.convertDatePhoto(photo)}

    elsif yearly_comparison.present?
      @years = RailsAdminSiteView.getPhotoYear(@photos)
      @closet_photos = []
      @years.each do |year|
        date_input = yearly_comparison.to_s + "-#{year}"
        @closet_photo = RailsAdminSiteView.getClosetDate(@photos, date_input, direction)
        @closet_photos << @closet_photo if @closet_photo.present?
      end
      @photos = @closet_photos.flatten.uniq
    end    
  end

end
