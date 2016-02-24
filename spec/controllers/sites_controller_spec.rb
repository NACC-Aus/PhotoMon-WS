require 'spec_helper'

describe SitesController do

  describe "GET 'index'" do
    it "returns http success" do 
      p = create(:project)
      controller.request.host = p.domain
      3.times {create(:site, project_id: p.id)}
      get 'index' 
      response.should be_success
      results = JSON.parse(response.body)
      results.size.should eql(3)
    end
  end

end
