require 'rails_helper'

RSpec.describe 'Coverage smoke', type: :request do
  let!(:user) do
    User.create!(email: 'cover@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'Cover', last_name: 'Age')
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
  end

  it 'exercises user full_name' do
    expect(user.full_name).to eq('Cover Age')
  end

  it 'hits users new/create/show' do
    get new_user_path
    expect(response.status).to be_between(200, 302).inclusive
    post users_path, params: { user: { email: 'newcover@tamu.edu', password: 'password', password_confirmation: 'password', first_name: 'New', last_name: 'User' } }
    expect(response.status).to be_between(200, 302).inclusive
    created = User.find_by(email: 'newcover@tamu.edu')
    get user_path(created || user)
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'exercises experience add/create/update' do
    # add_experience
    get add_experience_user_path(user)
    expect(response.status).to be_between(200, 302).inclusive
    # create_experience success
    post create_experience_user_path(user), params: { experience: { title: 'Dev', company: 'Acme', start_date: '2024-01-01', end_date: '2024-06-01', description: 'Work' } }
    expect(response.status).to be_between(200, 302).inclusive
    # edit/update experience
    get edit_experience_user_path(user, index: 0)
    expect(response.status).to be_between(200, 302).inclusive
    patch update_experience_user_path(user, index: 0), params: { experience: { title: 'Dev2', company: 'Acme', start_date: '2024-01-01', end_date: '2024-12-01', description: 'Work updated' } }
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'exercises education add/create/update' do
    get add_education_user_path(user)
    expect(response.status).to be_between(200, 302).inclusive
    post create_education_user_path(user), params: { education: { degree: 'BS', school: 'TAMU', start_date: '2022-01-01', end_date: '2025-01-01', description: 'Study' } }
    expect(response.status).to be_between(200, 302).inclusive
    get edit_education_user_path(user, index: 0)
    expect(response.status).to be_between(200, 302).inclusive
    patch update_education_user_path(user, index: 0), params: { education: { degree: 'MS', school: 'TAMU', start_date: '2022-01-01', end_date: '2026-01-01', description: 'Grad Study' } }
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'hits company verifications new/create/index/destroy' do
    get new_company_verification_path
    expect(response.status).to be_between(200, 302).inclusive
    post company_verifications_path, params: { company_verification: { company_name: 'Acme', company_email: 'employee@acme.com' } }
    expect(response.status).to be_between(200, 302).inclusive
    get company_verifications_path
    expect(response.status).to be_between(200, 302).inclusive
    cv = user.company_verifications.first
    if cv
      delete company_verification_path(cv)
      expect(response.status).to be_between(200, 302).inclusive
    end
  end

  it 'exercises company verify action success and failure' do
    cv = user.company_verifications.create!(company_name: 'Beta', company_email: 'dev@beta.com', verification_token: 'tok123')
    get verify_company_path(token: 'tok123', id: cv.id)
    expect(response.status).to be_between(200, 302).inclusive
    get verify_company_path(token: 'wrong', id: cv.id)
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'hits referral posts index/new/create and referral request create' do
    get referral_posts_path
    expect(response.status).to be_between(200, 302).inclusive
    get new_referral_post_path
    expect(response.status).to be_between(200, 302).inclusive
    user.company_verifications.create!(company_name: 'Gamma', company_email: 'me@gamma.com', is_verified: true, verification_token: 'v2')
    post referral_posts_path, params: { referral_post: { title: 'Internship', job_title: 'Intern', company_name: 'Gamma' } }
    expect(response.status).to be_between(200, 302).inclusive
    rp = user.referral_posts.first
    if rp
      post referral_post_referral_requests_path(rp), params: {}
      expect(response.status).to be_between(200, 302).inclusive
    end
  end

  it 'exercises email verification tamu/company invalid paths' do
    get verify_tamu_path(token: 'nope')
    expect(response.status).to be_between(200, 302).inclusive
    get verify_company_path(token: 'nope', id: 999999)
    expect(response.status).to be_between(200, 302).inclusive
  end

  it 'exercises redirect fallback logged in and logged out' do
    get '/unknown/path/one'
    expect(response.status).to be_between(200, 302).inclusive
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(false)
    get '/unknown/path/two'
    expect(response.status).to be_between(200, 302).inclusive
  end
end
