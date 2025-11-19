require "rails_helper"

RSpec.describe CompanyVerificationsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/company_verifications/new").to route_to("company_verifications#new")
    end

    it "routes to #show" do
      expect(get: "/company_verifications/1").to route_to("company_verifications#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/company_verifications/1/edit").to route_to("company_verifications#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/company_verifications").to route_to("company_verifications#create")
    end
  end
end
