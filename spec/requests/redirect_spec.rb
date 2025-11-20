require 'rails_helper'

RSpec.describe 'Redirect fallback', type: :request do
  describe 'GET unknown path' do
    let(:user) do
      User.create!(email: 'specuser@tamu.edu', password: 'password', password_confirmation: 'password')
    end

    context 'when logged in' do
      it 'redirects to the current user profile with a notice' do
        # Simulate login by setting session user_id (simplest approach without helper)
        get '/users/new' # touch session
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)

        get '/some/unknown/path'

        expect(response).to redirect_to(user_path(user))
        follow_redirect!
        expect(flash[:notice]).to eq('Redirected to your profile.')
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page with an error flash' do
        allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(false)
        get '/another/unknown/path'
        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(flash[:error]).to eq('You must be logged in to access this section')
      end
    end
  end
end
