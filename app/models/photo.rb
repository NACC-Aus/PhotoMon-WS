require 'zip/zip'
require 'zip_entry_adapter'
require 'open-uri'
class Photo
  include Mongoid::Document
  include Mongoid::Paperclip 
    
  NEW      = 'new'
  ACCEPTED = 'accepted'
  REJECTED   = 'rejected'
  NORTH = 'North'
  SOUTH = 'South'
  
  
  has_mongoid_attached_file :image, styles: {     large: ["1024", :jpg],      
                                                  iphone4: ["640x910#", :jpg], 
                                                  thumb: ["100x100#", :jpg] }, 
                                    convert_options: {all: ["-unsharp 0.3x0.3+5+0", "-quality 90%", "-auto-orient"]}, 
                                    processors: [:thumbnail] ,
                                    storage: Rails.env.production? ? :s3 : :filesystem,                    
                                    s3_permissions: :public_read,         
                                    s3_credentials: {access_key_id: CONFIG['amazon_access_key'],
                                                     secret_access_key: CONFIG['amazon_secret'],
                                                     bucket: CONFIG[:bucket]} 
  
  validates_presence_of :image
  validates_attachment_content_type :image, :content_type => %w(image/png image/jpg image/jpeg image/gif)

  field :direction, type: String, default: NORTH
  field :note, type:String
  field :status, type: String, default: NEW
  field :image_fingerprint, type: String
  field :created_at, type: DateTime
  field :uploaded_at, type: DateTime
  
  attr_accessor :delete_image 
  
  before_validation do    
    self.image.clear if self.delete_image == '1' 
  end  
  
  belongs_to :site, index: true, inverse_of: :photos
  belongs_to :user, index: true
  belongs_to :project, index: true
  
  belongs_to :north_guide_site, class_name: 'Site', inverse_of: :north_guide_photo
  belongs_to :south_guide_site, class_name: 'Site', inverse_of: :south_guide_photo
  belongs_to :east_guide_site, class_name: 'Site', inverse_of: :east_guide_photo
  belongs_to :west_guide_site, class_name: 'Site', inverse_of: :west_guide_photo
  belongs_to :point_guide_site, class_name: 'Site', inverse_of: :point_guide_photo
     
  validates_uniqueness_of :image_fingerprint, message: 'has already existed', scope: :project_id
  
  validates :user, :site, presence: true 
  validate :image_existed
  
  before_create do |record|
    record.uploaded_at = Time.now
  end

  before_save do |record|
    record.project_id = record.site.project_id if record.site && record.site.project_id
  end
  
  #before_image_post_process :update_timestamp
    
  index({image_fingerprint: 1})
  index({note: 1})
  
  scope :guide_photos, ->{self.or({:north_guide_site_id.ne => nil}, 
                                  {:south_guide_site_id.ne => nil}, 
                                  {:east_guide_site_id.ne => nil}, 
                                  {:west_guide_site_id.ne => nil},
                                  {:point_guide_site_id.ne => nil})}
  

index({ direction: 1 })
index({ status: 1 })
index({ image_fingerprint: 1 })
index({ created_at: 1 })
index({ uploaded_at: 1 })

  def image_s1024_url
    self.image.url(:large)
  end
  
  def thumbnails_url
    self.image.url(:thumb)
  end
  
  def new?
    status == NEW
  end
#38368670  
  def accepted?
    status == ACCEPTED
  end
  
  def rejected?
    status == REJECTED
  end
  
  def reject!
    self.update_attribute(:status, REJECTED)
  end
  
  def accept!
    self.update_attribute(:status, ACCEPTED)
  end
  
  def direction_enum
    ["North", "South", "East", "West", "Photo Point"]
  end
  
  def status_enum
    [NEW, ACCEPTED, REJECTED]
  end
  
  def name
    note.blank? ? "#{direction}#{id}" : "#{direction}##{note.truncate(15)}"
  end
  
  def as_json(options = {})
    {
     ID: id, 
     ImageUrl: image_s1024_url,
     Direction: direction,
     Status: status,
     Note: note,
     CreatedAt: created_at,
     SiteId: [north_guide_site_id, south_guide_site_id, west_guide_site_id, east_guide_site_id, point_guide_site_id, site_id].compact.uniq.first,
     ProjectId: project_id.to_s
    }
  end
  
  def self.bulk_create(file_name, user_id, photo_attrs = nil )     
    photos = []
    return photos unless File.exist?(file_name.to_s)

    Zip::ZipFile.open(file_name) do |file|
      file.each do |image_zip|         
        next unless image_zip.file?
        next if image_zip.name.index(" __MACOSX")
        begin          
          photo = self.new(photo_attrs)
          photo.user_id = user_id
          photo.image = image_zip

          f_path=File.join("log", image_zip.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          file.extract(image_zip, f_path) unless File.exist?(f_path)

          photo.created_at = get_created_time("#{Rails.root}/#{f_path}")
          photo.save!
          photos << photo
        rescue Exception => e
          puts "---------bulk_create error"
          puts e.message
          #just ignore the errors
        end
      end
    end
    FileUtils.rm(file_name)
    photos
  end

  def self.bulk_create_files(file_urls, file_names, file_dates, user_id, photo_attrs = {} )     
    photos = []
    file_urls.each_with_index do |file_url, index|
      begin
        photo = self.new(photo_attrs)
        photo.user_id = user_id
        photo.image = open(file_url)
          
        photo.image_file_name = file_names[index]
        photo.created_at = file_dates[index].to_time.utc

        photo.save!
        photos << photo
      rescue Exception => e
        puts "---------bulk_create_files error"
        puts e.message
        #just ignore the errors
      end
    end

    photos
  end

  def self.get_created_time(filename)
    meta = MiniExiftool.new filename
    
    time = if !meta['filemodifydate'].blank?
      meta["filemodifydate"]
    elsif !meta["fileinodechangedate"].blank?
      meta["fileinodechangedate"] 
    else
      File.mtime(filename)
    end

    time
  end
  
  protected
  
    def update_timestamp
      return unless self.created_at.blank?
      begin      
        origfile = image.queued_for_write[:original]      
        filename = origfile.path
        meta = MiniExiftool.new filename
        
        self.created_at = if !meta['datecreated'].blank?
          meta["datecreated"].split(":").join("-").to_date
        elsif !meta["createdate"].blank?
          meta["createdate"] 
        else
          
          File.mtime(filename)
        end
      rescue Exception => e
        puts e.message
      end
      self.created_at = Time.now if self.created_at.blank?
    end
    
    def image_existed
      return if !self.image_fingerprint_changed? && !self.new_record?
      if self.class.where(image_fingerprint: self.image_fingerprint, project_id: self.project_id).exists?
         self.errors.add(:base, 'This photo has already been added to the database')
      end
    end
end
