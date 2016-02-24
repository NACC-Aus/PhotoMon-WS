require 'spec_helper'

describe PhotosController do
 
  describe "POST 'create'" do
    it "works" do
      p1 = create(:project)
      p2 = create(:project)
      controller.request.host = p1.domain
      u = create(:user, project_ids: [p1._id,p2._id]) 
      site = create(:site, project_id: p1._id)
      params = {access_token: u.access_token,
                site_id: site._id, 
                image: fixture_file_upload(Rails.root.join('spec', 'factories', 'test-photo.jpg'), 'image/jpeg')}
      post 'create', params
      response.should be_success       
    end
    context "Errors" do 
      before(:each) do
        @p = create(:project)
        controller.request.host = @p.domain
      end
      it "Invalid Token" do  
        post 'create'
        response.status.should eql(401)
        response.body.should include("Invalid Token")
      end
      
      it "Invalid Parameters" do         
        u = create(:user, project_ids: [@p.id])
        params = {access_token: u.access_token,
                  site_id: 1,                 
                  image: fixture_file_upload(Rails.root.join('spec', 'factories', 'test-photo.jpg'), 'image/jpeg')}
        post 'create', params
        response.status.should eql(400)        
      end
      
    end
    
    
    
  end

end
