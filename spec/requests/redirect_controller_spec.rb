require "rails_helper"

RSpec.describe RedirectController, type: :request do
  let!(:user) do
    User.create!(
      email: "test@tamu.edu",
      password: "123456",
      first_name: "A",
      last_name: "B"
    )
  end

  describe "GET /fallback" do
    it "redirects logged-in users to profile" do
      login(user)
      get "/fallback"
      expect(response).to redirect_to(user_path(user))
    end

    it "redirects guests to login" do
      get "/fallback"
      expect(response).to redirect_to(new_session_path)
    end
  end
end
