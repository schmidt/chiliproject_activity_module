require File.dirname(__FILE__) + '/../spec_helper'

##
# Redmine 1.x tests only, the matching 0.9 tests may be found at the end of
# projects_controller_spec.rb
#
if Redmine::VERSION::MAJOR == 1
  describe ActivitiesController do
    before :each do
      @controller.stub!(:set_localization)

      @role = Factory.create(:non_member)
      @user = Factory.create(:admin)
      User.stub!(:current).and_return @user

      @params = {}
    end

    describe 'index' do
      describe 'with activated activity module' do
        before do
          @project = Factory.create(:project, :enabled_module_names => %w[activity wiki])
          @params[:id] = @project.id
        end

        it 'renders activity' do
          get 'index', @params
          response.should be_success
          response.should render_template 'index'
        end
      end

      describe 'without activated activity module' do
        before do
          @project = Factory.create(:project, :enabled_module_names => %w[wiki])
          @params[:id] = @project.id
        end

        it 'renders 403' do
          get 'index', @params
          response.status.should == '403 Forbidden'
          response.should render_template 'common/error'
        end
      end
    end
  end
end
