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
    User.create!(email: "alice.yi@tamu.edu",
                 first_name: "Alice",
                 last_name: "Yi",
                 password: "12346789")
  end

  let!(:user3) do
    User.create!(email: "shawn.han@tamu.edu",
                 first_name: "Shawn",
                 last_name: "Han",
                 password: "123456789")
  end

  let!(:verification1) do
    CompanyVerification.create!(
      user_id: user1.id,
      company_email: "john.smith@company.com",
      company_name:  "Example Company",
    )
  end

  let!(:verification2) do
    CompanyVerification.create!(
      user_id: user2.id,
      company_email: "alice.yi@company.com",
      company_name:  "Example Company",
    )
  end

  describe "show" do
    it "company verification 1 with John Smith" do
      session[:user_id] = user1.id
      get :show, params: { id: verification1.id }
      # TODO: Write an expect statement to check
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:company_verification)).to eq(verification1)
    end
  end

  describe "new" do
    it "company verification with Shawn Han" do
      session[:user_id] = user3.id
      get :new
      verification = CompanyVerification.find_by(user_id: session[:user_id])
      expect(assigns(:company_verification)).to eq(verification)
    end
  end

  # describe "edit" do
  #   it "company verification edit with Shawn Han" do
  #     session[:user_id] = user3.id
  #     get :edit
  #     expect(assigns(:company_verification)).to be_
  #   end
  # end
end
