class Project
  include Mongoid::Document
  field :name, type: String
  field :domain, type: String
  field :default_gallery_html, type: String
  field :public_gallery, type: Boolean
  
  has_and_belongs_to_many :users, index: true
  has_many :sites, dependent: :destroy
  has_many :photos, dependent: :destroy

  index({ name: 1 })
  index({ domain: 1 })
  index({ default_gallery_html: 1 })
  index({ public_gallery: 1 })

  def self.to_json_hash(projects)
    projects =  projects.to_a.map{|p| {uid: p._id, name: p.name}}
    {projects: projects}
  end
end
