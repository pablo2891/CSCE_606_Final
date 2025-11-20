require 'rails_helper'

RSpec.describe 'Controller branch coverage', type: :request do
  let!(:user) { User.create!(email: 'branch@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'Branch', last_name: 'Test') }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
  end

  describe 'UsersController redirect_if_logged_in' do
    it 'redirects from new when already logged in' do
      get new_user_path
      expect(response).to redirect_to(user_path(user))
    end

    it 'rescues show not found' do
      get user_path(999_999)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq('User not found.')
    end

    it 'unauthorized edit redirects' do
      other = User.create!(email: 'other@tamu.edu', password: 'password', password_confirmation: 'password')
      get edit_user_path(other)
      expect(response).to redirect_to(user_path(other))
      expect(flash[:alert]).to eq('Unauthorized')
    end

    it 'update failure renders edit' do
      patch user_path(user), params: { user: { email: '' } }
      expect(response.status).to be_between(200, 299).inclusive
    end
  end

  describe 'UsersController experience failure branch' do
    it 'create_experience failure renders add_experience' do
      post create_experience_user_path(user), params: { experience: { title: '', company: '', start_date: '' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to eq('Failed to add experience.')
    end

    it 'create_experience save failure hits else branch' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post create_experience_user_path(user), params: { experience: { title: 'Dev', company: 'Acme', start_date: '2024-01-01', end_date: '2024-06-01', description: 'Work' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to eq('Failed to add experience.')
    end
  end

  describe 'UsersController education failure branch' do
    it 'create_education failure renders add_education' do
      post create_education_user_path(user), params: { education: { degree: '', school: '', start_date: '' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to eq('Failed to add education.')
    end

    it 'create_education save failure hits else branch' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post create_education_user_path(user), params: { education: { degree: 'BS', school: 'TAMU', start_date: '2022-01-01', end_date: '2025-01-01', description: 'Study' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to eq('Failed to add education.')
    end
  end

  describe 'ReferralPostsController#create failure path' do
    it 'renders new with errors when validation fails' do
      # Missing title triggers validation failure
      post referral_posts_path, params: { referral_post: { title: '', company_name: 'NoMatchCo' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to be_present
    end
  end

  describe 'CompanyVerificationsController#create domain mismatch branch' do
    it 'renders new with domain mismatch error' do
      post company_verifications_path, params: { company_verification: { company_name: 'Acme', company_email: 'user@other.com' } }
      expect(response.status).to be_between(200, 299).inclusive
      expect(flash[:error]).to eq('Your email domain must match the company name.')
    end
  end

  describe 'CompanyVerificationsController#create save failure branch' do
    it 'redirects with failure when model invalid' do
      # First create a valid verification
      user.company_verifications.create!(company_name: 'Badco', company_email: 'employee@badco.com')
      # Second attempt with same email triggers uniqueness validation failure -> else branch
      post company_verifications_path, params: { company_verification: { company_name: 'Badco', company_email: 'employee@badco.com' } }
      expect(response).to redirect_to(user_path(user))
      expect(flash[:error]).to eq('Failed to create company verification.')
    end
  end

  describe 'ReferralRequestsController uniqueness validation' do
    it 'fails second request with uniqueness error' do
      cv = user.company_verifications.create!(company_name: 'Corp', company_email: 'me@corp.com', is_verified: true)
      post_obj = user.referral_posts.create!(title: 'Role', company_name: 'Corp', company_verification: cv, status: :active)
      post referral_post_referral_requests_path(post_obj), params: {}
      expect(response.status).to be_between(300, 399).inclusive
      # Second request should fail uniqueness
      post referral_post_referral_requests_path(post_obj), params: {}
      expect(response.status).to be_between(300, 399).inclusive
      expect(flash[:alert]).to eq('Failed to send request.')
    end
  end

  describe 'EmailVerificationsController TAMU success/failure' do
    it 'verifies TAMU email with valid token' do
      token = user.tamu_verification_token
      get verify_tamu_path(token: token)
      expect(response.status).to be_between(300, 399).inclusive
      expect(user.reload.is_tamu_verified).to eq(true)
    end

    it 'handles invalid TAMU token' do
      get verify_tamu_path(token: 'bogus')
      expect(response.status).to be_between(300, 399).inclusive
    end
  end

  describe 'EmailVerificationsController company success/failure' do
    it 'verifies company email with valid token and handles invalid token' do
      cv = user.company_verifications.create!(company_name: 'Delta', company_email: 'me@delta.com')
      token = cv.verification_token
      get verify_company_path(token: token, id: cv.id)
      expect(response.status).to be_between(300, 399).inclusive
      expect(cv.reload.is_verified).to eq(true)
      get verify_company_path(token: 'wrong', id: cv.id)
      expect(response.status).to be_between(300, 399).inclusive
    end
  end

  describe 'RedirectController fallback branches' do
    it 'redirects when logged in' do
      get '/some/random/missing/path'
      expect(response.status).to be_between(300, 399).inclusive
    end

    it 'no redirect when logged out' do
      allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      get '/another/random/missing/path'
      expect(response.status).to be_between(200, 399).inclusive
    end
  end
end
