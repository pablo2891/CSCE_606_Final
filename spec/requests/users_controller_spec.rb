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

    it "redirects if user not found" do
      login(user)
      get user_path(id: 99999)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq("User not found.")
    end
  end

  describe "GET /users/:id/edit" do
    it "renders edit template" do
      login(user)
      get edit_user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "redirects if unauthorized" do
      other_user = User.create!(email: "other@tamu.edu", password: "123456", first_name: "Other", last_name: "User")
      login(other_user)
      get edit_user_path(user)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq("Unauthorized")
    end
  end

  describe "PATCH /users/:id" do
    it "updates user profile" do
      login(user)
      patch user_path(user), params: { user: { first_name: "Updated" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.first_name).to eq("Updated")
    end

    it "renders edit on failure" do
      login(user)
      patch user_path(user), params: { user: { email: "" } }
      expect(response).to render_template(:edit)
    end
  end

  describe "Experience Actions" do
    before { login(user) }

    it "renders add_experience" do
      get add_experience_user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "creates experience" do
      post create_experience_user_path(user), params: { experience: { title: "Dev", company: "Tech", start_date: "2020-01-01" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.experiences_data.first["title"]).to eq("Dev")
    end

    it "fails to create experience" do
      # Assuming validation or error handling exists, but controller just pushes to array.
      # If model validation existed, we'd test failure.
      # Controller code: @user.save returns false if invalid.
      # Let's mock save failure to test the else branch.
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post create_experience_user_path(user), params: { experience: { title: "Dev" } }
      expect(response).to render_template(:add_experience)
      expect(flash[:error]).to eq("Failed to add experience.")
    end

    it "renders edit_experience" do
      user.experiences_data << { "title" => "Old", "company" => "OldCo" }
      user.save
      get edit_experience_user_path(user, index: 0)
      expect(response).to have_http_status(:success)
    end

    it "updates experience" do
      user.experiences_data << { "title" => "Old", "company" => "OldCo" }
      user.save
      patch update_experience_user_path(user, index: 0), params: { experience: { title: "New" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.experiences_data.first["title"]).to eq("New")
    end

    it "deletes experience" do
      user.experiences_data << { "title" => "ToDelete", "company" => "DeleteCo" }
      user.save
      delete delete_experience_user_path(user, index: 0)
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.experiences_data).to be_empty
    end

    it "handles failure to delete experience" do
      user.experiences_data << { "title" => "ToDelete", "company" => "DeleteCo" }
      user.save

      # Force @user.save to return false
      allow_any_instance_of(User).to receive(:save).and_return(false)

      delete delete_experience_user_path(user, index: 0)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq("Failed to delete experience entry.")
      expect(user.reload.experiences_data).not_to be_empty
    end
  end

  describe "Education Actions" do
    before { login(user) }

    it "renders add_education" do
      get add_education_user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "creates education" do
      post create_education_user_path(user), params: { education: { degree: "BS", school: "TAMU" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.educations_data.first["degree"]).to eq("BS")
    end

    it "fails to create education" do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post create_education_user_path(user), params: { education: { degree: "BS" } }
      expect(response).to render_template(:add_education)
      expect(flash[:error]).to eq("Failed to add education.")
    end

    it "renders edit_education" do
      user.educations_data << { "degree" => "Old", "school" => "OldU" }
      user.save
      get edit_education_user_path(user, index: 0)
      expect(response).to have_http_status(:success)
    end

    it "updates education" do
      user.educations_data << { "degree" => "Old", "school" => "OldU" }
      user.save
      patch update_education_user_path(user, index: 0), params: { education: { degree: "New" } }
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.educations_data.first["degree"]).to eq("New")
    end

    it "deletes education" do
      user.educations_data << { "degree" => "ToDelete", "school" => "DeleteU" }
      user.save
      delete delete_education_user_path(user, index: 0)
      expect(response).to redirect_to(user_path(user))
      expect(user.reload.educations_data).to be_empty
    end

    it "handles failure to delete education" do
      user.educations_data << { "degree" => "ToDelete", "school" => "DeleteU" }
      user.save

      # Force @user.save to return false
      allow_any_instance_of(User).to receive(:save).and_return(false)

      delete delete_education_user_path(user, index: 0)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to eq("Failed to delete education entry.")
      expect(user.reload.educations_data).not_to be_empty
    end
  end
end
