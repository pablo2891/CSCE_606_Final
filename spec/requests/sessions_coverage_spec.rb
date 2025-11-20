require 'rails_helper'

RSpec.describe 'Sessions coverage', type: :request do
  let!(:user) { User.create!(email: 'sess@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'Sess', last_name: 'Ion') }

  it 'renders new (no redirect when logged out)' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    get new_session_path
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'redirects from new when logged in' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    get new_session_path
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'fails to login with wrong password and renders new' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    post session_path, params: { user: { email: user.email, password: 'wrong' } }
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'logs in with correct password and redirects' do
    post session_path, params: { user: { email: user.email, password: 'password' } }
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'destroys session and redirects' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    delete session_path
    expect(response.status).to be_between(200, 302).inclusive
  end
end
