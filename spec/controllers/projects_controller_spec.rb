require 'spec_helper'

describe ProjectsController do

  describe "GET 'index'" do
    it "super admin gets unsuccessfully" do 
      p1 = create(:project)
      controller.request.host = p1.domain
      p2 = create(:project)
      p3 = create(:project)
      p4 = create(:project)
      u = create(:user, admin: true)
      params = {access_token: u.access_token}
      sign_in :user, u
      get 'index', params
      response.status.should eql(401)
    end

    it "project admin gets his projects" do 
      p1 = create(:project)
      controller.request.host = p1.domain
      p2 = create(:project)
      p3 = create(:project)
      p4 = create(:project)
      u = create(:user, project_ids: [p1.id], admin_project_ids: [p1.id])
      params = {access_token: u.access_token}
      sign_in :user, u
      get 'index', params
      response.should be_success
      results = JSON.parse(response.body)
      results["projects"].size.should eql(1)

    end

  end

end
