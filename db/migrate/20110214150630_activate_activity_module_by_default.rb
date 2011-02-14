class ActivateActivityModuleByDefault < ActiveRecord::Migration
  def self.up
    RedmineActivityModule.activate_activity_module_for_all_projects
    RedmineActivityModule.add_activity_module_from_default_settings
  end

  def self.down
    RedmineActivityModule.deactivate_activity_module_for_all_projects
    RedmineActivityModule.remove_activity_module_from_default_settings
  end
end
