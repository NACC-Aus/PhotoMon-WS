# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
User.create(email: 'abc@example.com', 
            first_name: 'ABC', 
            last_name: 'Pham',
            password: '123456789',
            password_confirmation: '123456789',
            admin: true) if User.count == 0


# update Site friendly slug
Site.all.each do |s|
  s.apply_slug
	s.save :validate => false
end

User.each do |u|
  begin
    u.project_ids = u.project_id ? [u.project_id] : []
    u.admin_project_ids = u.project_id ? [u.project_id] : []
    u.save
  rescue
    p '================'
    p u
  end
end