require 'spec_helper'

describe SiteController do

  render_views

  context 'the home page' do

    it 'should correctly render the page' do
      get :index
      response.should render_template(:index)
    end

    it 'should be successful' do
      get :index
      response.should be_successful
    end

  end

end
