require 'rails_helper'

RSpec.describe "EmailVerifications", type: :request do
  describe "GET /verify_tamu" do
    let(:user) { User.create!(email: "test@tamu.edu", password: "password", first_name: "Test", last_name: "User", is_tamu_verified: false) }

    context "with valid token" do
      it "verifies the user and redirects to root" do
        get verify_tamu_path(token: user.tamu_verification_token)

        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq("Your TAMU email has been successfully verified!")

        user.reload
        expect(user.is_tamu_verified).to be true
        expect(user.tamu_verified_at).to be_present
      end
    end

    context "with invalid token" do
      it "does not verify the user and redirects with error" do
        get verify_tamu_path(token: "invalid_token")

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("Invalid or expired verification link.")

        user.reload
        expect(user.is_tamu_verified).to be false
      end
    end
  end

  describe "GET /verify_company" do
    let(:user) { User.create!(email: "company_owner@tamu.edu", password: "password", first_name: "Owner", last_name: "User") }
    let(:company_verification) { CompanyVerification.create!(user: user, company_name: "Test Corp", company_email: "hr@testcorp.com", is_verified: false) }

    context "with valid token" do
      it "verifies the company and redirects to root" do
        get verify_company_path(token: company_verification.verification_token)

        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to eq("Company email has been successfully verified!")

        company_verification.reload
        expect(company_verification.is_verified).to be true
        expect(company_verification.verified_at).to be_present
      end
    end

    context "with invalid token" do
      it "does not verify the company and redirects with error" do
        get verify_company_path(token: "invalid_token")

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq("Invalid or expired verification link.")

        company_verification.reload
        expect(company_verification.is_verified).to be false
      end
    end
  end
end
