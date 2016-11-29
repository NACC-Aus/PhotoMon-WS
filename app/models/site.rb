class Site
  include Mongoid::Document
  include Mongoid::Slug

  field :name, type: String
  slug :name

  field :latitude, type: String
  field :longitude, type: String  
  field :gallery_html, type: String
  field :last_photo_taken, type: DateTime
  has_many :photos, inverse_of: :site, dependent: :delete
   
  has_one :north_guide_photo, class_name: 'Photo', inverse_of: 'north_guide_site'
  has_one :south_guide_photo, class_name: 'Photo', inverse_of: 'south_guide_site'
  has_one :east_guide_photo, class_name: 'Photo', inverse_of: 'east_guide_site'
  has_one :west_guide_photo, class_name: 'Photo', inverse_of: 'west_guide_site'
  has_one :point_guide_photo, class_name: 'Photo', inverse_of: 'point_guide_site'
  
  belongs_to :project
  validates_presence_of :name, :latitude, :longitude

  index({ name: 1 })
  index({ latitude: 1 })
  index({ longitude: 1 })

  before_save do
    if north_guide_photo || south_guide_photo || east_guide_photo || west_guide_photo  || point_guide_photo
      self.update_last_photo_taken!(false)
      true
    end
  end
  
  def as_json(options = {})
    hash = {
      ID: id, 
      Name: name,
      Latitude: latitude,
      Longitude: longitude,
      slug: slug,
      ProjectId: project_id.to_s,
      lastPhotoTaken: last_photo_taken
    }
  end
  
  [:north_guide_photo, :south_guide_photo, :east_guide_photo, :west_guide_photo, :point_guide_photo].each do |method_name|
    define_method "#{method_name}_id" do   
      self.send(method_name).try :id    
    end    
    
    define_method "#{method_name}_id=" do |value|
      return if value.to_s == self.send("#{method_name}_id").to_s     
      photo = Photo.where(id: value).first
      direction_field = "#{method_name}_id".gsub('photo','site')
      Photo.where(direction_field => self.id).update_all(direction_field => nil)    
      self.send("#{method_name}=", photo) 
    end    
  end

  def update_last_photo_taken!(need_save = true)
    self.last_photo_taken = photos.max(:created_at)

    [:north_guide_photo, :south_guide_photo, :east_guide_photo, :west_guide_photo, :point_guide_photo].each do |method_name|
      guide_photo = send(method_name)
      next unless guide_photo && guide_photo.created_at

      if last_photo_taken.nil? || guide_photo.created_at > last_photo_taken
        self.last_photo_taken = guide_photo.created_at
      end
    end

    self.save(validate: false) if need_save
    true
  end

  def self.update_last_photo_taken!(site_ids = nil)
    if site_ids
      sites = Site.where(:id.in => site_ids)
    else
      sites = Site.all
    end

    sites.each do |site|
      site.update_last_photo_taken!
    end
  end
end
 