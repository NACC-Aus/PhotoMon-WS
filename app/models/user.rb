class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :rememberable
         #:registerable,
         #:recoverable,         
         #:validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password
  validates_uniqueness_of :email, :access_token
  ## Recoverable
  #field :reset_password_token,   :type => String
  #field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  field :access_token,  type: String
  field :admin, type: Boolean, default: false
  field :first_name, type: String
  field :last_name, type:String
  field :name, type: String
  
  has_many :photos
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :admin_projects, class_name: 'Project'
  
  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  index({email: 1})
  index({access_token: 1})
  index({name: 1})
  before_save :generate_access_token, :generate_name

  
  def self.login(email, password, project_id)
    users = User.where({:email => email})
    if project_id
      user = users.any_of({:project_ids.in => [project_id]},{:admin_project_ids.in => [project_id]}).first
    else
      user = users.first
    end

    return nil if user.nil? || !user.try(:valid_password?, password)
    user
  end
  
  def self.login_by_access_token(access_token, project_id)
    users = self.where({:access_token => access_token})
    if project_id
      users.any_of({:project_ids.in => [project_id]},{:admin_project_ids.in => [project_id]}).first
    else
      users.first
    end
  end
  
  private
    def generate_access_token
      self.access_token = UUID.new.generate if self.access_token.blank?
    end
    
    def generate_name
      self.name = "#{first_name} #{last_name}"
    end
end
