class SessionsController < ApplicationController
  def create
    user = User.login(params[:email], params[:password], current_project.try(:id))
    if user
      render json: {AccessToken: user.access_token}
    else
      render json:{Error: "Invalid Email or Password"}, status: 400
    end
  end
end
