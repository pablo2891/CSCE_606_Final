require "rails_helper"

RSpec.describe UsersController, type: :request do
  let!(:user) do
    User.create!(
      email: "test@tamu.edu",
      password: "123456",
      first_name: "A",
      last_name: "B"
    )
  end

  describe "GET /signup" do
    it "renders new" do
      # Temporarily disable require_login for this test
      allow_any_instance_of(ApplicationController).to receive(:require_login)
      get new_user_path
      expect(response.body).to include("Sign Up")
    end
  end

  describe "POST /users" do
    it "creates user and redirects to profile" do
      # Temporarily disable require_login for this test
      allow_any_instance_of(ApplicationController).to receive(:require_login)
      post users_path, params: {
        user: {
          first_name: "New",
          last_name: "User",
          email: "new@tamu.edu",
          password: "123456",
          password_confirmation: "123456"
        }
      }
      # After signup, user is redirected to profile (not login)
      expect(response).to redirect_to(user_path(User.last))
    end

    it "renders new with errors" do
      # Temporarily disable require_login for this test
      allow_any_instance_of(ApplicationController).to receive(:require_login)
      post users_path, params: {
        user: {
          first_name: "",
          last_name: "",
          email: "bad",
          password: "123",
          password_confirmation: "456"
        }
      }
      expect(response.body).to include("error")
    end
  end

  describe "GET /profile" do
    it "assigns current_user" do
      login(user)
      get user_path(user)
      expect(response.body).to include(user.email)
    end
  end
end
