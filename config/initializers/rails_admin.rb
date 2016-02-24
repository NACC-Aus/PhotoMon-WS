# RailsAdmin config file. Generated on January 07, 2013 14:54
# See github.com/sferik/rails_admin for more informations
require 'rails_admin_bulk_upload'
require 'rails_admin_bulk_files_upload'
require 'rails_admin_accept'
require 'rails_admin_bulk_accept'
require 'rails_admin_site_view'
require 'rails_admin_view'
require 'rails_admin/config/actions/rails_admin_delete'
require 'csv_converter'

RailsAdmin.config do |config|
  config.actions do

     # root actions
    dashboard                     # mandatory
    # collection actions
    index                         # mandatory
    new
    export

    bulk_delete
    bulk_accept
    # bulk_upload
    bulk_files_upload
    # member actions
    accept
    show
    site_view
    view
    edit
    delete
  end


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['NACC', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated
  config.authorize_with :cancan
  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['User']

  # Include specific models (exclude the others):
  # config.included_models = ['User']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]

  config.total_columns_width = 1000
  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:



  ###  User  ###

  # config.model 'User' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

  #   # Found associations:



  #   # Found columns:

  #     configure :_id, :bson_object_id
  #     configure :email, :text
  #     configure :password, :password         # Hidden
  #     configure :password_confirmation, :password         # Hidden
  #     configure :remember_created_at, :datetime
  #     configure :sign_in_count, :integer
  #     configure :current_sign_in_at, :datetime
  #     configure :last_sign_in_at, :datetime
  #     configure :current_sign_in_ip, :text
  #     configure :last_sign_in_ip, :text
  #     configure :access_token, :text
  #     configure :admin, :boolean
  #     configure :first_name, :text
  #     configure :last_name, :text

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end
  config.model User do
    edit do
      field :first_name, :string
      field :last_name, :string
      field :email, :string
      field :password, :password
      field :password_confirmation, :password

      field :admin do
        visible do
          bindings[:view]._current_user.admin?
        end
      end

      field :projects do
        label "Viewable projects"
      end

      field :admin_projects do
        label "Manageable projects"
      end
    end
  end

  config.model Project do
    list do 
      [:_id, :name, :domain, :default_gallery_html, :public_gallery].each{|f| field f}
    end
    edit do
      field :name 
      field :domain
      field :default_gallery_html
      field :public_gallery
      field :users do
        associated_collection_cache_all { true }
      end
      field :sites do
        associated_collection_cache_all { true }
      end
      # field :photos do
      #   associated_collection_cache_all { true }
      # end
      
     end
  end



  config.model 'Photo' do
    configure :thumbnails_url, :string
    configure :image_s1024_url, :string
    configure :created_at

    configure :user do
      searchable :name
    end
    list do
      field :image do
        :image_s1024_url
      end

      [:note, :direction, :status].each{|f| field f}

      field :site do
        searchable [{:site => :name}]
        queryable true
      end

      field :project do
        searchable [{:project => :name}]
        queryable true
      end

      [:user, :uploaded_at, :created_at].each{|f| field f}
    end

    export do
      [:id,:image,:direction,:note,:status,:image_fingerprint,:thumbnails_url,:image_s1024_url].each{|f| field f}

      if :csv
        field :created_at do
          strftime_format "%Y/%m/%d %H:%M:%S"
        end
        field :uploaded_at do
          strftime_format "%Y/%m/%d %H:%M:%S"
        end
      else
        [:created_at,:uploaded_at].each{|f| field f}
      end
      [:site,:user,:project].each{|f| field f}
    end
 
    edit do
      field :image do
        help ''
      end
      field :note
      field :direction

      field :site do
        associated_collection_cache_all true

        associated_collection_scope do
          # bindings[:object] & bindings[:controller] are available, but not in scope's block!
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
            scope = scope.where(:project_id.in => project_ids)
          }
        end
      end

      field :status do
        visible do
          bindings[:view]._current_user.admin?
        end
      end

      field :user_id, :hidden do
        default_value do
          bindings[:view]._current_user.id
        end

        visible do
          bindings[:object].new_record?
        end
      end

      field :user do
        visible do
          !bindings[:object].new_record? && bindings[:view]._current_user.admin?
        end
      end

      field :created_at, :hidden do
        visible true
      end

    end
  end


  config.model Site do
    configure :north_guide_photo
    configure :south_guide_photo
    configure :east_guide_photo
    configure :west_guide_photo
    # list do
    #   [:_id, :name, :slugs, :latitude, :longitude, :gallery_html, :project, :north_guide_photo, :south_guide_photo, :west_guide_photo, :east_guide_photo, :uploaded_at, :created_at].each{|f| field f}
    # end
    edit do
      field :name, :string
      field :project, :belongs_to_association
      field :latitude, :map do
        google_api_key CONFIG[:google_api_key]
        default_latitude(-33.873651)  # Sydney, Australia
        default_longitude(151.20688960000007)
        help ''
      end

      field :gallery_html

      field :north_guide_photo do
        visible do
          !bindings[:object].new_record?
        end
        associated_collection_scope do
          site = bindings[:object]
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
             scope = scope.where(site_id: site.id, :project_id.in => project_ids).or({direction: 'North'}, {direction: nil}, {direction: ''}) if site.present?
          }
        end
      end
      field :south_guide_photo do
        visible do
          !bindings[:object].new_record?
        end
        associated_collection_scope do
          site = bindings[:object]
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
             scope = scope.where(site_id: site.id, :project_id.in => project_ids).or({direction: 'South'}, {direction: nil}, {direction: ''}) if site.present?
          }
        end
      end
      field :west_guide_photo do
        visible do
          !bindings[:object].new_record?
        end
        associated_collection_scope do
          site = bindings[:object]
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
             scope = scope.where(site_id: site.id, :project_id.in => project_ids).or({direction: 'West'}, {direction: nil}, {direction: ''}) if site.present?
          }
        end
      end
      field :east_guide_photo do
        visible do
          !bindings[:object].new_record?
        end
        associated_collection_scope do
          site = bindings[:object]
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
             scope = scope.where(site_id: site.id, :project_id.in => project_ids).or({direction: 'East'}, {direction: nil}, {direction: ''}) if site.present?
          }
        end
      end

      field :point_guide_photo do
        visible do
          !bindings[:object].new_record?
        end
        associated_collection_scope do
          site = bindings[:object]
          project_ids = bindings[:view]._current_user.admin_project_ids
          Proc.new { |scope|
             scope = scope.where(site_id: site.id, :project_id.in => project_ids).or({direction: 'Photo Point'}, {direction: nil}, {direction: ''}) if site.present?
          }
        end
      end

      field :photos do
        visible do
          !bindings[:object].new_record? && bindings[:view]._current_user.admin?
        end
      end
      field :longitude do
        view_helper :hidden_field
        # I added these next two lines to solve this
        label :hidden => true
        help ""
      end

    end
    #include_all_fields
    #field :lng, :string
  end
end
