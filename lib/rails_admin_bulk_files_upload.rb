require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminBulkFilesUpload
end

module RailsAdmin
  module Config
    module Actions
      class BulkFilesUpload < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
              
        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:post, :get]
        end
        
        register_instance_option :visible? do 
         authorized? && (bindings[:abstract_model].to_s ==  'Photo')
        end
        
        register_instance_option :link_icon do
          'icon-upload' 
        end
        
        register_instance_option :controller do
          Proc.new do
            if request.get?
              @object = Photo.new
              render @action.template_name
            elsif request.post?
              @object = Photo.new
              @object.site_id = params[:photo][:site_id]
              @object.user_id = current_user.id
              @object.note = params[:photo][:note]
              @object.status = params[:photo][:status]
              @object.direction = params[:photo][:direction]
              
              if @object.site_id && @object.user_id
                notice = t("admin.flash.successful", :name => @model_config.label, :action => t("admin.actions.#{@action.key}.done"))
                #Copy the  zipfile to safety places

                Photo.delay.bulk_create_files(params[:photo][:image], params[:photo][:name], params[:photo][:date], current_user.id, site_id: @object.site_id, project_id: @object.project_id, direction: @object.direction, note: @object.note, status: @object.status)
                redirect_to back_or_index, :flash => { :success => notice }
              else               
                handle_save_error :bulk_files_upload
              end
             end
          end
        end

        
        
      end
    end
  end
end