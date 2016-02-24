require 'spec_helper'

describe User do
  before(:each) do 
   @p = create(:project)
  end
  
 context "Default values" do
   it "works" do
     u = User.new
     u.admin?.should be_false
     u.project_admin?.should be_false
   end
 end
 
 context "Generate access_token" do
   it "generates access_token" do     
     u = create(:user)
     u.access_token.should_not be_nil
     #auto re-generate access-token if it's null
     u.access_token = ''
     u.save
     u.access_token.should_not be_blank
   end 
 end
 
 context ".login" do
   
   it "returns users" do     
     email = '123@abc.com'
     password = '123456' 
     create(:user,project_id: @p.id, email: '123@abc.com', password: password, password_confirmation: password)     
     User.login(email,password, @p.id).is_a?(User).should be_true
   end
   
   it "return nil" do
     email = '123@abc.com'
     password = '123456' 
     create(:user, project_id: @p.id, email: '123@abc.com', password: password, password_confirmation: password)
     User.login('some-email@abc.com', password, @p.id).should be_nil
     User.login(email, 'wrong password', @p.id).should be_nil
     User.login(nil,nil, nil).should be_nil
   end
 end
 
 context ".login_by_access_token" do
   it "returns user" do
     access_token = "access-token-1234"
     u = create(:user, access_token: access_token, project_id: @p.id)
     User.login_by_access_token(access_token, @p.id).should eql(u)
   end
   
   it "returns nil" do
     create(:user, project_id: @p.id)
     User.login_by_access_token("some access-token", @p.id).should be_nil
   end
 end
end 
  