require 'spec_helper'

describe "Routing" do
  it "POST /sessions.json" do
    {
      post: "/sessions.json"      
     }.should route_to(controller: 'sessions', action: 'create', format: 'json')
  end
  
  it "POST /photos.json" do
    {
      post: "/photos.json"      
     }.should route_to(controller: 'photos', action: 'create', format: 'json')
  end
  
  it "GET /sites.json" do
    {get: "/sites.json"}.should route_to(controller: 'sites', action: 'index', format: 'json')
  end

  it "GET /projects.json" do
    {get: "/projects.json"}.should route_to(controller: 'projects', action: 'index', format: 'json')
  end
end 