require 'rails_helper'

RSpec.describe "ReferralPosts Search", type: :request do
  let!(:user) { User.create!(email: "user@tamu.edu", password: "password", password_confirmation: "password", first_name: "Test", last_name: "User") }
  let!(:other) { User.create!(email: "other@tamu.edu", password: "password", password_confirmation: "password", first_name: "Other", last_name: "User") }

  let!(:p_tesla) do
    other.referral_posts.create!(title: "Engineer I", job_title: "Engineer", company_name: "Tesla", department: "R&D", location: "Austin", company_verification: other.company_verifications.create!(company_name: "Tesla", company_email: "r@tesla.com", is_verified: true), status: :active, questions: [])
  end

  let!(:p_google) do
    other.referral_posts.create!(title: "Engineer II", job_title: "Engineer", company_name: "Google", department: "Search", location: "Mountain View", company_verification: other.company_verifications.create!(company_name: "Google", company_email: "r@google.com", is_verified: true), status: :active, questions: [])
  end

  let!(:p_amazon) do
    other.referral_posts.create!(title: "Engineer III", job_title: "Engineer", company_name: "Amazon", department: "Retail", location: "Seattle", company_verification: other.company_verifications.create!(company_name: "Amazon", company_email: "r@amazon.com", is_verified: true), status: :active, questions: [])
  end

  before do
    post session_path, params: { user: { email: user.email, password: 'password' } }
  end

  it "returns only Tesla when query=Tesla" do
    get referral_posts_path, params: { query: 'Tesla' }
    expect(response.body).to include('Tesla')
    expect(response.body).not_to include('Google')
    expect(response.body).not_to include('Amazon')
  end

  it "returns all active posts ordered by created_at when query is blank" do
    # set created_at to ensure ordering (newest first)
    p_tesla.update!(created_at: 3.days.ago)
    p_google.update!(created_at: 2.days.ago)
    p_amazon.update!(created_at: 1.day.ago)

    get referral_posts_path, params: { query: '' }
    # Check order: Amazon then Google then Tesla
    body = response.body
    expect(body.index('Amazon')).to be < body.index('Google')
    expect(body.index('Google')).to be < body.index('Tesla')
  end

  it "is resilient to malicious input (SQL safety)" do
    expect { get referral_posts_path, params: { query: "Tesla'; DROP TABLE users; --" } }.not_to raise_error
    expect(response).to have_http_status(:ok)
  end
end
