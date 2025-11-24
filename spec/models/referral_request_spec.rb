require 'rails_helper'

RSpec.describe ReferralRequest, type: :model do
  let(:user) { User.create!(email: "ruser@tamu.edu", password: "password", password_confirmation: "password") }
  let(:poster) { User.create!(email: "poster@tamu.edu", password: "password", password_confirmation: "password") }
  let(:company_verification) { CompanyVerification.create!(user: poster, company_email: "hr@company.com", company_name: "Company") }
  let(:post) { ReferralPost.create!(user: poster, company_verification: company_verification, company_name: "Company", title: "T", job_title: "Dev") }

  it 'returns an empty hash when submitted_data is nil' do
    req = ReferralRequest.new(user: user, referral_post: post)
    expect(req.submitted_data_hash).to eq({})
  end

  it 'returns the submitted_data when present' do
    req = ReferralRequest.new(user: user, referral_post: post, submitted_data: { 'q1' => 'a' })
    expect(req.submitted_data_hash).to eq({ 'q1' => 'a' })
  end

  it 'prevents duplicate requests by same user for same post' do
    ReferralRequest.create!(user: user, referral_post: post)
    dup = ReferralRequest.new(user: user, referral_post: post)
    expect(dup).not_to be_valid
    expect(dup.errors[:user_id]).to be_present
  end
end
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
