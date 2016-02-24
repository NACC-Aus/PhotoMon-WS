class SitesController < ApplicationController
  before_filter :project_required!

  def index
    render json: current_project.sites
  end
end
