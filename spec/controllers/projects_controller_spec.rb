require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  before :each do
    @controller.stub!(:set_localization)

    @role = Factory.create(:non_member)
    @user = Factory.create(:admin)
    User.stub!(:current).and_return @user

    @params = {}
  end

  def clear_settings_cache
    Rails.cache.clear
  end

  # this is the base method for get, post, etc.
  def process(*args)
    clear_settings_cache
    result = super
    clear_settings_cache
    result
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

  describe 'new' do
    integrate_views

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

      it "renders 'new'" do
        get 'new', @params
        response.should be_success
        response.should render_template 'new'
      end

      it 'renders available modules list with activity being selected' do
        get 'new', @params

        response.should have_tag('fieldset.box:last-of-type') do
          with_tag 'legend', :text => /Modules.*/
          with_tag "input[name='#{'project[enabled_module_names][]'}'][value=wiki][checked=checked]"
          with_tag "input[name='#{'project[enabled_module_names][]'}'][value=activity][checked=checked]"
        end
      end
    end

    describe 'without activated activity module' do
      before do
        Setting.default_projects_modules = %w[wiki]
      end

      it "renders 'new'" do
        get 'new', @params
        response.should be_success
        response.should render_template 'new'
      end

      it 'renders available modules list without activity being selected' do
        get 'new', @params

        response.should have_tag('fieldset.box:last-of-type') do
          with_tag 'legend', :text => /Modules.*/
          with_tag    "input[name='#{'project[enabled_module_names][]'}'][value=wiki][checked=checked]"
          with_tag    "input[name='#{'project[enabled_module_names][]'}'][value=activity]"
          without_tag "input[name='#{'project[enabled_module_names][]'}'][value=activity][checked=checked]"
        end
      end
    end
  end

  describe 'settings' do
    integrate_views

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
          with_tag "input[name='enabled_module_names[]'][value=wiki][checked=checked]"

          with_tag "input[name='enabled_module_names[]'][value=activity][checked=checked]"
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
          with_tag    "input[name='enabled_module_names[]'][value=wiki][checked=checked]"

          with_tag    "input[name='enabled_module_names[]'][value=activity]"
          without_tag "input[name='enabled_module_names[]'][value=activity][checked=checked]"
        end
      end
    end
  end
end
