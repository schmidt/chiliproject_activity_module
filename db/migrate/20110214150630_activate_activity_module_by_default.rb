class ActivateActivityModuleByDefault < ActiveRecord::Migration
  def self.up
    ActivityModule.activate_activity_module_for_all_projects
    ActivityModule.add_activity_module_from_default_settings
  end

  def self.down
    ActivityModule.deactivate_activity_module_for_all_projects
    ActivityModule.remove_activity_module_from_default_settings
  end
end
