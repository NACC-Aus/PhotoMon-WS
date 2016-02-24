class ProjectsController < ApplicationController
  before_filter :user_required!
  
  def index
  	current_ability = Ability.new(app_user)
    projects = Project.accessible_by(current_ability, params[:action].to_sym)
    render json: Project.to_json_hash(projects), status: 200
  end
  
end