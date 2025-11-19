require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) do
    User.create!(
      first_name: "Test",
      last_name: "User",
      email: "test@tamu.edu",
      password: "123456"
    )
  end

  describe "GET /new" do
    it "renders login page" do
      get new_session_path
      expect(response).to have_http_status(200)
    end
  end
end
