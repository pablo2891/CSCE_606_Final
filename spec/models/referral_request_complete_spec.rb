require 'rails_helper'

RSpec.describe ReferralRequest, type: :model do
  let(:user) { User.create!(email: "test@tamu.edu", password: "password", password_confirmation: "password") }
  let(:poster) { User.create!(email: "poster@tamu.edu", password: "password", password_confirmation: "password") }
  let(:company_verification) { poster.company_verifications.create!(company_name: "Corp", company_email: "p@corp.com", is_verified: true) }
  let(:post_record) { ReferralPost.create!(user: poster, company_verification: company_verification, company_name: "Corp", title: "Job", job_title: "Dev") }

  describe "#submitted_data_hash" do
    it "returns hash when submitted_data is present" do
      request = ReferralRequest.create!(
        user: user,
        referral_post: post_record,
        submitted_data: { "question" => "answer" }
      )

      expect(request.submitted_data_hash).to be_a(Hash)
      expect(request.submitted_data_hash["question"]).to eq("answer")
    end

    it "returns empty hash when submitted_data is nil" do
      request = ReferralRequest.create!(
        user: user,
        referral_post: post_record,
        submitted_data: nil
      )

      expect(request.submitted_data_hash).to eq({})
    end

    it "returns empty hash when submitted_data is empty" do
      request = ReferralRequest.create!(
        user: user,
        referral_post: post_record,
        submitted_data: {}
      )

      expect(request.submitted_data_hash).to eq({})
    end
  end

  describe "status enum" do
    it "supports all status values" do
      request = ReferralRequest.create!(user: user, referral_post: post_record)

      expect(request.pending?).to be true

      request.approved!
      expect(request.approved?).to be true

      request.rejected!
      expect(request.rejected?).to be true

      request.withdrawn!
      expect(request.withdrawn?).to be true
    end
  end
end
