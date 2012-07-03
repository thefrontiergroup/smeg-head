require 'spec_helper'

describe UsersController do

  render_views

  context 'the user profile page' do

    it 'should correctly render the page' do
      get :show
      response.should render_template(:index)
    end

  end

end
