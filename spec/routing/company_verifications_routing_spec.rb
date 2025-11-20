require "rails_helper"

RSpec.describe CompanyVerificationsController, type: :routing do
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
  describe "routing" do
    it "routes to #index" do
      expect(get: "/company_verifications").to route_to("company_verifications#index")
    end
    it "routes to #new" do
      expect(get: "/company_verifications/new").to route_to("company_verifications#new")
    end

    it "routes to #create" do
      expect(post: "/company_verifications").to route_to("company_verifications#create")
    end

    it "routes to #destroy" do
      expect(post: "/company_verifications").to route_to("company_verifications#create")
    end

    it "routes to #verify" do
      expect(get: "/company_verifications/#{verification1.id}/verify").to route_to(
        controller: "company_verifications",
        action: "verify",
        id: verification1.id.to_s   # must be a string
      )
    end
  end
end
