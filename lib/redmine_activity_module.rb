module RedmineActivityModule
  def self.activate_activity_module_for_all_projects
    Project.find(:all).each do |p|
      p.enabled_module_names = ["activity"] | p.enabled_module_names
    end
  end

  def self.deactivate_activity_module_for_all_projects
    Project.find(:all).each do |p|
      p.enabled_module_names = ["activity"] - p.enabled_module_names
    end
  end

  def self.add_activity_module_from_default_settings
    Setting["default_projects_modules"] = ["activity"] | Setting.default_projects_modules
  end
  
  def self.remove_activity_module_from_default_settings
    Setting["default_projects_modules"] = ["activity"] - Setting.default_projects_modules
  end
end
