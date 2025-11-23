require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let!(:user) do
    User.create!(
      email: "dashboard@tamu.edu",
      password: "123456",
      first_name: "Dashboard",
      last_name: "User"
    )
  end

  describe "GET /index" do
    it "returns http success" do
      # Login first
      post session_path, params: { user: { email: user.email, password: "123456" } }

      get "/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end
end
