require File.dirname(__FILE__) + '/../spec_helper'

describe RedmineActivityModule do
  describe '.activate_activity_module_for_all_projects' do
    describe 'when activity module was active' do
      before do
        @enabled_module_names = %w[activity issue_tracking time_tracking news wiki]
        2.times {
          Factory.build(:project, :enabled_module_names => @enabled_module_names)
        }
      end

      it 'keeps all previously activated modules' do
        RedmineActivityModule.activate_activity_module_for_all_projects
        @enabled_module_names.each do |name|
          Project.find(:all).should be_all { |p| p.enabled_module_names.include?(name) }
        end
      end
    end

    describe 'when activity module was not active' do
      before do
        @enabled_module_names = %w[issue_tracking time_tracking news wiki]
        2.times {
          Factory.build(:project, :enabled_module_names => @enabled_module_names)
        }
      end

      it 'activates the activity module' do
        RedmineActivityModule.activate_activity_module_for_all_projects
        Project.find(:all).should be_all { |p| p.enabled_module_names.include?("activity") }
      end

      it 'keeps all previously activated modules' do
        RedmineActivityModule.activate_activity_module_for_all_projects
        @enabled_module_names.each do |name|
          Project.find(:all).should be_all { |p| p.enabled_module_names.include?(name) }
        end
      end
    end
  end

  describe '.deactivate_activity_module_for_all_projects' do
    describe 'when activity module was active' do
      before do
        @enabled_module_names = %w[activity issue_tracking time_tracking news wiki]
        2.times {
          Factory.build(:project, :enabled_module_names => @enabled_module_names)
        }
      end

      it 'removes activity from list of activated modules' do
        RedmineActivityModule.deactivate_activity_module_for_all_projects
        Project.find(:all).should be_none { |p| p.enabled_module_names.include? 'activity' }
      end

      it 'keeps all other activated modules' do
        RedmineActivityModule.deactivate_activity_module_for_all_projects
        (@enabled_module_names - ['activity']).each do |name|
          Project.find(:all).should be_all { |p| p.enabled_module_names.include?(name) }
        end
      end
    end

    describe 'when activity module was not active' do
      before do
        @enabled_module_names = %w[issue_tracking time_tracking news wiki]
        2.times {
          Factory.build(:project, :enabled_module_names => @enabled_module_names)
        }
      end

      it 'does not activates the activity module' do
        RedmineActivityModule.deactivate_activity_module_for_all_projects
        Project.find(:all).should be_none { |p| p.enabled_module_names.include?("activity") }
      end

      it 'keeps all previously activated modules' do
        RedmineActivityModule.deactivate_activity_module_for_all_projects
        @enabled_module_names.each do |name|
          Project.find(:all).should be_all { |p| p.enabled_module_names.include?(name) }
        end
      end
    end
  end

  describe '(global settings)' do
    before(:all) do
      @previous_projects_modules = Setting['default_projects_modules']
    end

    after(:all) do
      Setting['default_projects_modules'] = @previous_projects_modules
    end

    describe '.add_activity_module_from_default_settings' do
      describe 'when activity module was not part of default_projects_modules' do
        before do 
          @default_projects_modules = %w[issue_tracking time_tracking news wiki]
          Setting["default_projects_modules"] = @default_projects_modules
        end

        it 'adds activity to the list of the default_projects_modules' do
          RedmineActivityModule.add_activity_module_from_default_settings
          Setting["default_projects_modules"].should include('activity')
        end

        it 'does not change the other default_projects_modules' do
          RedmineActivityModule.add_activity_module_from_default_settings
          @default_projects_modules.should be_all { |n| Setting['default_projects_modules'].include?(n) }
        end
      end

      describe 'when activity module was already part of default_projects_modules' do
        before do
          @default_projects_modules = %w[activity issue_tracking time_tracking news wiki]
          Setting["default_projects_modules"] = @default_projects_modules
        end

        it 'keeps all previous members of the default_projects_modules' do
          RedmineActivityModule.add_activity_module_from_default_settings
          @default_projects_modules.should be_all { |n| Setting['default_projects_modules'].include?(n) }
        end
      end
    end

    describe '.remove_activity_module_from_default_settings' do
      describe 'when activity module was not part of default_projects_modules' do
        before do
          @default_projects_modules = %w[issue_tracking time_tracking news wiki]
          Setting["default_projects_modules"] = @default_projects_modules
        end

        it 'does not add activity to the list of default_projects_modules' do
          RedmineActivityModule.remove_activity_module_from_default_settings
          Setting['default_projects_modules'].should_not include('activity')
        end

        it 'keeps all previous members of the default_projects_modules' do
          RedmineActivityModule.remove_activity_module_from_default_settings
          @default_projects_modules.should be_all { |n| Setting['default_projects_modules'].include?(n) }
        end
      end

      describe 'when activity module was already part of default_projects_modules' do
        before do
          @default_projects_modules = %w[activity issue_tracking time_tracking news wiki]
          Setting["default_projects_modules"] = @default_projects_modules
        end

        it 'removes activity from the list of default_projects_modules' do
          RedmineActivityModule.remove_activity_module_from_default_settings
          Setting['default_projects_modules'].should_not include('activity')
        end

        it 'keeps all previous members of the default_projects_modules' do
          RedmineActivityModule.remove_activity_module_from_default_settings
          (@default_projects_modules - ['activity']).should be_all { |n| Setting['default_projects_modules'].include?(n) }
        end
      end
    end
  end
end
