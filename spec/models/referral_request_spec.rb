require 'rails_helper'
require 'securerandom'

RSpec.describe ReferralRequest, type: :model do
  let(:user) { User.create!(email: "req+#{SecureRandom.hex(6)}@tamu.edu", password: "password", password_confirmation: "password") }
  let(:poster) { User.create!(email: "poster2+#{SecureRandom.hex(6)}@tamu.edu", password: "password", password_confirmation: "password") }
  let(:company_verification) { CompanyVerification.create!(user: poster, company_email: "hr+#{SecureRandom.hex(6)}@ex.com", company_name: "Ex") }
  let(:post_record) { ReferralPost.create!(user: poster, company_verification: company_verification, company_name: "Ex", title: "Role", job_title: "Software Engineer") }

  it "is valid when user requests a post" do
    req = ReferralRequest.new(user: user, referral_post: post_record)
    expect(req).to be_valid
  end

  it "does not allow duplicate requests by same user for same post" do
    ReferralRequest.create!(user: user, referral_post: post_record)
    dup = ReferralRequest.new(user: user, referral_post: post_record)
    expect(dup).not_to be_valid
    expect(dup.errors[:user_id]).to be_present
  end

  it 'allows enum transitions' do
    r = ReferralRequest.create!(user: user, referral_post: post_record)
    expect(r.pending?).to be true
    r.approved!
    expect(r.approved?).to be true
  end
end
