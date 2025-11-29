require 'rails_helper'
require 'securerandom'

RSpec.describe ReferralPost, type: :model do
  let(:user) { User.create!(email: "poster+#{SecureRandom.hex(6)}@tamu.edu", password: "password", password_confirmation: "password") }
  let(:company_verification) { CompanyVerification.create!(user: user, company_email: "hr+#{SecureRandom.hex(6)}@example.com", company_name: "Example") }

  it "is valid with required attributes" do
    post = ReferralPost.new(user: user, company_verification: company_verification, company_name: "Example", title: "Job", job_title: "Software Engineer")
    expect(post).to be_valid
  end

  it "validates presence of title" do
    post = ReferralPost.new(user: user, company_verification: company_verification, company_name: "Example", job_title: "Software Engineer")
    expect(post).not_to be_valid
    expect(post.errors[:title]).to be_present
  end

  it 'scopes active posts' do
    ReferralPost.create!(user: user, company_verification: company_verification, company_name: 'Example', title: 'A', job_title: 'Engineer', status: :active)
    ReferralPost.create!(user: user, company_verification: company_verification, company_name: 'Example', title: 'B', job_title: 'Developer', status: :closed)
    expect(ReferralPost.active_posts.all? { |p| p.status == 'active' || p.status == :active || p.status.to_s == 'active' || p.active? }).to be true
  end

  it 'returns empty array for questions when nil and stringifies elements' do
    rp = ReferralPost.create!(user: user, company_verification: company_verification, company_name: 'Example', title: 'Q', job_title: 'Dev', questions: nil)
    expect(rp.questions).to eq([])
    rp2 = ReferralPost.create!(user: user, company_verification: company_verification, company_name: 'Example', title: 'Q2', job_title: 'Dev', questions: [ 1, :two ])
    expect(rp2.questions).to all(be_a(String))
  end

  describe ".search" do
    let(:user1) { User.create!(email: "test@tamu.edu", password: "password") }
    let(:company_verification1) { CompanyVerification.create!(user: user, company_email: "hr@tech.com", company_name: "Tech Corp", is_verified: true) }

    let!(:post1) { ReferralPost.create!(user: user1, company_verification: company_verification1, company_name: "Tech Corp", title: "Backend Developer", job_title: "Developer", department: "Engineering", location: "College Station") }
    let!(:post2) { ReferralPost.create!(user: user1, company_verification: company_verification1, company_name: "Biz Inc", title: "Frontend Engineer", job_title: "Engineer", department: "Design", location: "Austin") }

    it 'returns posts matching the company_name' do
      expect(ReferralPost.search("Tech")).to include(post1)
      expect(ReferralPost.search("Tech")).not_to include(post2)
    end

    it 'returns posts matching the title' do
      expect(ReferralPost.search("Frontend")).to include(post2)
      expect(ReferralPost.search("Frontend")).not_to include(post1)
    end

    it 'returns posts matching the job_title' do
      expect(ReferralPost.search("Developer")).to include(post1)
      expect(ReferralPost.search("Developer")).not_to include(post2)
    end

    it 'returns posts matching the department' do
      expect(ReferralPost.search("Design")).to include(post2)
      expect(ReferralPost.search("Design")).not_to include(post1)
    end

    it 'returns posts matching the location' do
      expect(ReferralPost.search("College Station")).to include(post1)
      expect(ReferralPost.search("College Station")).not_to include(post2)
    end

    it 'is case-insensitive' do
      expect(ReferralPost.search("tech corp")).to include(post1)
    end

    it 'returns an empty relation if no matches' do
      expect(ReferralPost.search("Nonexistent")).to be_empty
    end
  end
end
