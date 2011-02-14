require File.dirname(__FILE__) + '/../../test_helper'

class RedmineActivityModule::RedmineActivityModuleTest < ActionController::TestCase
  should "test activate_activity_module_for_all_projects"
  should "test deactivate_activity_module_for_all_projects"
  should "test add_activity_module_from_default_settings"
  should "test remove_activity_module_from_default_settings"
end

