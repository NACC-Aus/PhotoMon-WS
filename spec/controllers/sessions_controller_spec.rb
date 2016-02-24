require 'spec_helper'

describe SessionsController do
  before(:each) do
    @p = create(:project)
    controller.request.host = @p.domain
  end
  describe "POST 'create'" do
    it "works" do
      email = "email@abc.com"
      password = "134"
      u = create(:user, project_id: @p.id)
      post 'create',{email: u.email, password: u.password}
      response.should be_success
      response.body.should include(u.access_token)
    end
    
    it "return error" do
      post "create", {email: 'some email', password: ''}
      response.status.should eql(400)
      response.body.should include("Error")
    end
  end

end
