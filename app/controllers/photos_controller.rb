class PhotosController < ApplicationController
  before_filter :user_required!, :project_required!
  
  def create
    params[:project_id] = current_project.id    
    photo = app_user.photos.create(params)            
    if photo.new_record? && photo.errors[:image_fingerprint].blank?
      render json:{Error: photo.errors.full_messages}, status: 400
    else
      photo = Photo.where(image_fingerprint: photo.image_fingerprint, project_id: current_project.id).first if photo.new_record?
      render json: photo
    end 
  end 
  
  def update
    photo = app_user.photos.find(params[:id])
    photo.note = params[:note]
    photo.save!    
    render json: photo
  end
  
  def index
    
    photos = current_project.photos.guide_photos
    uniq_photos = {}
    photos.each do |photo|
      uniq_photos["#{photo.site_id}#{photo.direction}"] = photo
    end
    render json: uniq_photos.values
  end
  
end
