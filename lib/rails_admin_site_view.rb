require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminSiteView

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
end

module RailsAdmin
  module Config
    module Actions
      class SiteView < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :http_methods do
          [:post,:get]
        end

        register_instance_option :visible? do
          authorized? && bindings[:object].is_a?(Site) rescue false
        end

        # http://twitter.github.com/bootstrap/base-css.html#icons
        register_instance_option :link_icon do
          'icon-eye-open'
        end

        register_instance_option :route_fragment do
          'siteview'
        end

        register_instance_option :authorization_key do
          :siteview
        end

        register_instance_option :member do
          true
        end

        register_instance_option :controller do
          Proc.new do
            begin
              @photos = Rails.cache.read("#{@object.name}-#{object.id}")
              if @photos.nil?
                @photos = @object.photos.all
                Rails.cache.write("#{@object.name}-#{object.id}", @photos, expires_in: 1.minutes )
              end

              if request.post?
                direction = params[:direction]
                from_date = params[:from_date]
                to_date = params[:to_date]
                yearly_comparison = params[:yearly_comparison]

                if direction.present? && direction.to_s != "All"
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
            rescue => e
              Rails.logger.info "=============================================="
              Rails.logger.info "Somethings went wrong in RailsAdminSiteView"
              Rails.logger.info "=============================================="
            ensure

            end
          end
        end
      end
    end
  end
end
