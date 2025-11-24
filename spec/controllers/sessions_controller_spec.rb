require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  render_views

  let!(:user) { User.create!(email: 'login@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'L', last_name: 'O') }

  describe 'POST #create' do
    it 'logs in with correct credentials' do
      post :create, params: { user: { email: user.email, password: 'password' } }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(user_path(user))
    end

    it 'renders new on bad credentials' do
      post :create, params: { user: { email: user.email, password: 'bad' } }
      expect(session[:user_id]).to be_nil
      expect(response).to render_template(:new)
    end
  end

  describe 'DELETE #destroy' do
    it 'clears the session and redirects to login' do
      session[:user_id] = user.id
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(new_session_path)
    end
  end
end
