# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyVerificationsController, type: :controller do
  render_views

  before do
    User.destroy_all
    CompanyVerification.destroy_all
  end

  let!(:user1) do
    User.create!(email: "john.smith@tamu.edu",
                 first_name: "John",
                 last_name: "Smith",
                 password: "12346789")
  end

  let!(:user2) do
    User.create!(email: "shawn.han@tamu.edu",
                 first_name: "Shawn",
                 last_name: "Han",
                 password: "123456789")
  end

  let!(:verification1) do
    CompanyVerification.create!(
      user_id: user1.id,
      company_email: "john.smith@meta.com",
      company_name:  "Meta",
      is_verified: true
    )
  end

  let!(:verification2) do
    CompanyVerification.create!(
      user_id: user1.id,
      company_email: "john.smith@amazon.com",
      company_name:  "Amazon"
    )
  end

  describe "index" do
    it "company verification index for user John Smith pending" do
      session[:user_id] = user1.id
      get :index
      expect(assigns(:pending_verifications)).to include(verification2)
    end

    it "company verification index for user John Smith verified" do
      session[:user_id] = user1.id
      get :index
      expect(assigns(:verified_verifications)).to include(verification1)
    end
  end

  describe "new" do
    it "company verification with Shawn Han" do
      session[:user_id] = user2.id
      get :new
      expect(assigns(:company_verification)).to be_a_new(CompanyVerification)
    end
  end

  describe "create" do
    before do
      session[:user_id] = user2.id
      @current_user = User.find(session[:user_id])
    end
    it "creates a valid verification entry" do
      get :create, params: { company_verification: { company_name: "Apple", company_email: "shawn.han@apple.com" } }
      expect(@current_user.company_verifications.exists?(company_name: "Apple")).to eq(true)
    end

    it "prevents ain invalid verification entry with mismatching company names" do
      get :create, params: { company_verification: { company_name: "Apple", company_email: "shawn.han@meta.com" } }
      expect(flash[:error]).to eq("Your email domain must match the company name.")
    end

    it "prevents ain invalid verification entry with bad input" do
      get :create, params: { company_verification: { company_name: "Apple", company_email: "@apple.com" } }
      expect(flash[:error]).to eq("Failed to create company verification.")
      expect(response).to redirect_to(user_path(@current_user))
    end
  end

  describe "verify" do
    before do
      session[:user_id] = user1.id
    end
    it "fails if the token is incorrect" do
      get :verify, params: { id: verification2.id, token: "incorrect_token" }
      expect(response).to redirect_to(root_path)
    end

    it "passes if the token is incorrect" do
      get :verify, params: { id: verification2.id, token: verification2.verification_token }
      expect(response).to redirect_to(company_verifications_path)
    end
  end

  describe "destroy" do
    before do
      session[:user_id] = user1.id
    end
    it "deletes an entry in company verification" do
      deleted_id = verification2.id
      get :destroy, params: { id: deleted_id }
      expect(CompanyVerification.exists?(id: deleted_id)).to eq(false)
    end
  end
end
