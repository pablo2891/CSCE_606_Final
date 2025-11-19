require "rails_helper"

RSpec.describe SessionsController, type: :request do
  let!(:user) do
    User.create!(
      email: "test@tamu.edu",
      password: "123456",
      first_name: "A",
      last_name: "B"
    )
  end

  describe "GET /login" do
    it "renders new for guest" do
      get new_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Log In")
    end

    it "redirects logged-in user" do
      login(user)
      get new_session_path
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "POST /login" do
    it "logs in successfully" do
      post session_path, params: { user: { email: user.email, password: "123456" } }
      expect(response).to redirect_to(user_path(user))
    end

    it "renders new with error on fail" do
      post session_path, params: { user: { email: user.email, password: "WRONG" } }
      expect(response.body).to include("Invalid email or password")
    end

    it "redirects if already logged in" do
      login(user)
      post session_path, params: { user: { email: user.email, password: "123456" } }
      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "DELETE /logout" do
    it "logs out user" do
      login(user)
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
