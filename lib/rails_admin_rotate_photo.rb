require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminRotatePhoto
end

module RailsAdmin
  module Config
    module Actions
      class RotatePhoto < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      
        register_instance_option :http_methods do
          [:put]
        end

        register_instance_option :visible? do        
          authorized? && bindings[:object].is_a?(Photo) rescue false 
        end

        register_instance_option :authorization_key do
          :rotate_photo
        end

        register_instance_option :route_fragment do
          'rotate_photo'
        end

        register_instance_option :member do
          true
        end
        
        register_instance_option :controller do 
          Proc.new do 
            if request.get?
             
            elsif request.put?                            
              @object.rotate = params[:angle].to_i
              @object.image.reprocess!
              
              respond_to do |format|
                format.html { redirect_to_on_success }
                format.js { render :json => { :id => @object.id.to_s, :label => @model_config.with(:object => @object).object_label } }
              end
            end
          end
        end
      end
    end
  end
end

