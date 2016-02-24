require 'spec_helper'

describe Site do
  context "validation" do
    it "requires name, latitude, longitude" do
      s = Site.new
      s.valid?.should be_false
      s.errors[:name].should_not be_blank
      s.errors[:latitude].should_not be_blank
      s.errors[:longitude].should_not be_blank
    end
  end
  
  context "#as_json" do
    it "works" do
      s = create(:site)
      json = s.to_json
      [:name, :longitude, :latitude].each do |f|
        json.should include(s.send(f))
      end
    end    
  end
end
