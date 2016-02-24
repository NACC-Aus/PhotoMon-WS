require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminView
end

module RailsAdmin
  module Config
    module Actions
      class View < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          authorized? && bindings[:object].is_a?(Photo) rescue false
        end

        # http://twitter.github.com/bootstrap/base-css.html#icons
        register_instance_option :link_icon do
          'icon-eye-open'
        end

        register_instance_option :route_fragment do
          'view'
        end

        register_instance_option :authorization_key do
          :view
        end

        register_instance_option :member do
          true
        end

        register_instance_option :controller do
          Proc.new do

          end
        end
      end
    end
  end
end

