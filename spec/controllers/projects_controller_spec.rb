require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  before :each do
    @controller.stub!(:set_localization)

    @role = Factory.create(:non_member)
    @user = Factory.create(:admin)
    User.stub!(:current).and_return @user

    @params = {}
  end

  describe 'show' do
    integrate_views

    describe 'with activated activity module' do
      before do
        @project = Factory.create(:project, :enabled_module_names => %w[activity])
        @params[:id] = @project.id
      end

      it 'renders show' do
        get 'show', @params
        response.should be_success
        response.should render_template 'show'
      end

      it 'renders main menu with activity tab' do
        get 'show', @params

        response.should have_tag('#main-menu') do
          with_tag 'a.activity'
        end
      end
    end

    describe 'without activated activity module' do
      before do
        @project = Factory.create(:project, :enabled_module_names => %w[wiki])
        @params[:id] = @project.id
      end

      it 'renders show' do
        get 'show', @params
        response.should be_success
        response.should render_template 'show'
      end

      it 'renders main menu without activity tab' do
        get 'show', @params

        response.should have_tag('#main-menu') do
          without_tag 'a.activity'
        end
      end
    end
  end

  ##
  # the action to create a new project is called 'add' in 0.9 and new in 1.x
  #
  if Redmine::VERSION::MAJOR == 0
    create_new_project_action = 'add'
  else
    create_new_project_action = 'new'
  end

  describe create_new_project_action do
    integrate_views

    if Redmine::VERSION::MAJOR == 0
      enabled_module_checkbox_name = 'enabled_modules[]'
    else
      enabled_module_checkbox_name = 'project[enabled_module_names][]'
    end

    before(:all) do
      @previous_projects_modules = Setting.default_projects_modules
    end

    after(:all) do
      Setting.default_projects_modules = @previous_projects_modules
    end

    describe 'with activity in Setting.default_projects_modules' do
      before do
        Setting.default_projects_modules = %w[activity wiki]
      end

      it "renders #{create_new_project_action}" do
        get create_new_project_action, @params
        response.should be_success
        response.should render_template create_new_project_action
      end

      it 'renders available modules list with activity being selected' do
        get create_new_project_action, @params

        response.should have_tag('fieldset.box:last-of-type') do
          with_tag 'legend', :text => 'Modules'
          with_tag "input[name='#{enabled_module_checkbox_name}'][value=wiki][checked=checked]"
          with_tag "input[name='#{enabled_module_checkbox_name}'][value=activity][checked=checked]"
        end
      end
    end

    describe 'without activated activity module' do
      before do
        Setting.default_projects_modules = %w[wiki]
      end

      it "renders #{create_new_project_action}" do
        get create_new_project_action, @params
        response.should be_success
        response.should render_template create_new_project_action
      end

      it 'renders available modules list without activity being selected' do
        get create_new_project_action, @params

        response.should have_tag('fieldset.box:last-of-type') do
          with_tag 'legend', :text => 'Modules'
          with_tag    "input[name='#{enabled_module_checkbox_name}'][value=wiki][checked=checked]"
          with_tag    "input[name='#{enabled_module_checkbox_name}'][value=activity]"
          without_tag "input[name='#{enabled_module_checkbox_name}'][value=activity][checked=checked]"
        end
      end
    end
  end

  describe 'settings' do
    integrate_views

    if Redmine::VERSION::MAJOR == 0
      enabled_module_checkbox_name = 'enabled_modules[]'
    else
      enabled_module_checkbox_name = 'enabled_module_names[]'
    end


    describe 'with activity in Setting.default_projects_modules' do
      before do
        @project = Factory.create(:project, :enabled_module_names => %w[activity wiki])
        @params[:id] = @project.id
      end

      it 'renders settings/modules' do
        get 'settings', @params.merge(:tab => 'modules')
        response.should be_success
        response.should render_template 'settings'
      end

      it 'renders available modules list with activity being selected' do
        get 'settings', @params.merge(:tab => 'modules')

        response.should have_tag('#modules-form') do
          with_tag "input[name='#{enabled_module_checkbox_name}'][value=wiki][checked=checked]"

          with_tag "input[name='#{enabled_module_checkbox_name}'][value=activity][checked=checked]"
        end
      end
    end

    describe 'without activated activity module' do
      before do
        @project = Factory.create(:project, :enabled_module_names => %w[wiki])
        @params[:id] = @project.id
      end

      it 'renders settings/modules' do
        get 'settings', @params.merge(:tab => 'modules')
        response.should be_success
        response.should render_template 'settings'
      end

      it 'renders available modules list without activity being selected' do
        get 'settings', @params.merge(:tab => 'modules')

        response.should have_tag('#modules-form') do
          with_tag    "input[name='#{enabled_module_checkbox_name}'][value=wiki][checked=checked]"

          with_tag    "input[name='#{enabled_module_checkbox_name}'][value=activity]"
          without_tag "input[name='#{enabled_module_checkbox_name}'][value=activity][checked=checked]"
        end
      end
    end
  end




  ##
  # Redmine 0.9 only tests, the matchin 1.x test may be found in the
  # activities_controller_spec.rb
  #
  if Redmine::VERSION::MAJOR == 0
    describe '/activity' do
      describe 'with activated activity module' do
        before do
          @project = Factory.create(:project, :enabled_module_names => %w[activity wiki])
          @params[:id] = @project.id
        end

        it 'renders activity' do
          get 'activity', @params
          response.should be_success
          response.should render_template 'activity'
        end
      end

      describe 'without activated activity module' do
        before do
          @project = Factory.create(:project, :enabled_module_names => %w[wiki])
          @params[:id] = @project.id
        end

        it 'renders 403' do
          get 'activity', @params
          response.status.should == '403 Forbidden'
          response.should render_template 'common/403'
        end
      end
    end
  end
end
