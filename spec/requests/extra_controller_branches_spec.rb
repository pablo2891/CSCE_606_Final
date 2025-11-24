require 'rails_helper'

RSpec.describe 'Extra controller branches', type: :request do
  let!(:user) do
    User.create!(
      email: "extra@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Extra",
      last_name: "User"
    )
  end

  let!(:other_user) do
    User.create!(
      email: "other_extra@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Other",
      last_name: "User"
    )
  end

  before do
    # set session directly for request specs (rack_session_access)
    post "/__rack_session", params: { rack_session: { user_id: user.id } }
  end

  describe 'PATCH /users/:id with remove_resume' do
    it 'accepts remove_resume and handles purge_later without error' do
      # attach a fixture resume to the user so purge_later has a receiver
      fixture = Rails.root.join('spec', 'fixtures', 'files', 'sample.pdf')
      if File.exist?(fixture)
        user.resume.attach(io: File.open(fixture), filename: 'sample.pdf', content_type: 'application/pdf')
        user.save!
      end

      # ensure authenticated for this request (stub require_login and current_user to be safe)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        patch user_path(user), params: { user: { first_name: 'Changed' }, remove_resume: '1' }

        expect(response).to redirect_to(user_path(user))
        follow_redirect!
        # ensure update happened and flash was set
        expect(user.reload.first_name).to eq('Changed')
        expect(flash[:notice]).to match(/Profile updated successfully/)
    end
  end

  describe 'PATCH /users/:id unauthorized update' do
    it 'prevents other users from updating profile' do
      # login as other user
      delete session_path
      post session_path, params: { user: { email: other_user.email, password: 'password123' } }

      patch user_path(user), params: { user: { first_name: 'Hacker' } }

      expect(response).to redirect_to(user_path(user))
      follow_redirect!
      expect(flash[:alert]).to eq('Unauthorized')
    end
  end

  describe 'POST /users/:id/create_experience blank fields' do
    it 'renders add_experience when required fields are missing' do
      # post with missing required fields (title/company/start_date)
      # ensure authenticated for this request (stub require_login and current_user to be safe)
      allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        # Force save failure to hit the failure branch reliably
        allow_any_instance_of(User).to receive(:save).and_return(false)

        post create_experience_user_path(user), params: { experience: { title: '', company: '' } }

        expect(response).to render_template(:add_experience)
        expect(flash[:error]).to eq('Failed to add experience.')
    end
  end
end
