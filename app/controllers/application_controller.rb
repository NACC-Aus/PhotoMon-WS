class AccessDenied < Exception;end

class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from AccessDenied, with: :handle_exception
  helper_method :current_project

protected
  def current_project
    @project ||= project_by_id || project_by_domain
  end

  def project_by_id
    Project.where(_id: params[:project_id]).first
  end
  
  def project_by_domain
    Project.where(domain: request.host).first
  end

  def handle_exception
    render json: {Error: 'Invalid Token or domain name'}, status: 401
  end
  
  def user_required!
    raise AccessDenied unless app_user
  end
  
  def project_required!
    raise AccessDenied unless current_project
  end
  
  def app_user
    @app_user ||= User.login_by_access_token(params[:access_token], current_project.try(:_id))
  end
end
