class Ability
  include CanCan::Ability

  def initialize(user)
    can :access, :rails_admin   # grant access to rails_admin
    can :dashboard              # grant access to the dashboard   
    user ||= User.new
  
    if user.admin?
      can :manage, :all

    else
      # For Read-Only
      can :read, Photo, :project_id.in => user.project_ids + user.admin_project_ids
      can :create, Photo, :project_id.in => user.project_ids + user.admin_project_ids
      can :read, Site, :project_id.in => user.project_ids + user.admin_project_ids
      can :siteview, Site, :project_id.in => user.project_ids + user.admin_project_ids
      
      can :read, Project, :_id.in => user.project_ids + user.admin_project_ids
      
      # For Project Admin
      can :read, User, :project_ids.in => user.admin_project_ids
      can :update, User, :project_ids.in => user.admin_project_ids
      can :create, User, :project_ids.in => user.admin_project_ids
      can :manage, Photo, :project_id.in => user.admin_project_ids
      can :manage, Site, :project_id.in => user.admin_project_ids
      
      can :update, Project, :_id.in => user.admin_project_ids

      if user.admin_project_ids.blank?
        cannot :create, Site
        cannot :create, User
      end
    end
  end
end
