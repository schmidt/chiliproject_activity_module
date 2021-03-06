require 'redmine'
require 'activity_module'
require 'activity_module/version'

Redmine::Plugin.register :activity_module do
  name 'ChiliProject Activity Module Plugin'
  author 'Gregor Schmidt'
  description 'This Plugin makes activity a module, such that it can be activated and deactivated on a per-project setting.'
  version ActivityModule::Version.full
  url 'http://github.com/finnlabs/chiliproject_activity_module'
  author_url 'http://www.finn.de/'
end


require 'dispatcher'
Dispatcher.to_prepare :activity_module do
  require_dependency 'application_controller'
  require_dependency 'redmine/access_control'

  require_dependency 'activities_controller'
  ActivitiesController.class_eval do
    def verify_activities_module_activated
      render_403 if @project && !@project.module_enabled?("activity")
    end

    before_filter :verify_activities_module_activated
    private :verify_activities_module_activated
  end

  ApplicationController.master_helper_module.class_eval do
    def allowed_node?(node, user, project)
      if node.name == :activity
        project.module_enabled?("activity")
      else
        super
      end
    end
  end

  class << Redmine::AccessControl; self; end.class_eval do
    def available_project_modules_with_activity
      list = available_project_modules_without_activity
      unless list.include? 'activity'
        list.unshift 'activity'
      end
      list
    end
    alias_method_chain :available_project_modules, :activity unless instance_methods.include? "available_project_modules_without_activity"
  end

  if RAILS_ENV == 'test'
    def (ActionController::IntegrationTest).inherited(sub)
      if sub.name == 'MenuManagerTest'
        sub.send(:define_method, :setup) do
          ActivityModule.activate_activity_module_for_all_projects
        end
      end
      super
    end
    def (ActionController::TestCase).inherited(sub)
      if sub.name == 'ActivitiesControllerTest'
        sub.send(:define_method, :setup) do
          ActivityModule.activate_activity_module_for_all_projects
        end
      end
      super
    end
  end
end
