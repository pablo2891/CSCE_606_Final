require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  let!(:user) do
    User.create!(email: "res.user@tamu.edu", first_name: "Res", last_name: "User", password: "password")
  end

  before do
    session[:user_id] = user.id

    experience = {
      title: "Senior Developer",
      company: "Tech Corp",
      start_date: 1.year.ago.strftime('%Y-%m-%d'), # e.g., "2024-11-29"
      end_date: Date.today.strftime('%Y-%m-%d'), # e.g., "2026-11-29"
      description: "Built amazing things."
    }

    education = {
      degree: "B.S. Computer Science",
      school: "Texas A&M University",
      start_date: 5.year.ago.strftime('%Y-%m-%d'), # Make sure this is <= Today
      end_date: 1.year.ago.strftime('%Y-%m-%d'),   # Make sure this is >= Today
      description: "Minor in Cybersecurity"
    }
    user.experiences_data << experience
    user.educations_data  << education
  end

  describe "POST #create_experience" do
    it "rejects malformed start date" do
      post :create_experience, params: {
        id: user.id,
        experience: {
          title: "Senior Developer",
          company: "Tech Corp",
          start_date: 1.year.from_now.strftime('%Y-%m-%d'), # e.g., "2024-11-29"
          end_date: 1.year.ago.strftime('%Y-%m-%d'), # e.g., "2026-11-29"
          description: "Built amazing things."
        }
      }
      expect(flash[:error]).to eq "Failed to add experience."
      expect(response).to render_template(:add_experience)
    end

    it "rejects malformed end date" do
      post :create_experience, params: {
        id: user.id,
        experience: {
          title: "Senior Developer",
          company: "Tech Corp",
          start_date: 1.year.ago.strftime('%Y-%m-%d'), # e.g., "2024-11-29"
          end_date: 1.year.from_now.strftime('%Y-%m-%d'), # e.g., "2026-11-29"
          description: "Built amazing things."
        }
      }
      expect(flash[:error]).to eq "Failed to add experience."
      expect(response).to render_template(:add_experience)
    end
  end


  describe "POST #create_education" do
    it "rejects malformed start date" do
      post :create_education, params: {
        id: user.id,
        education: {
          degree: "B.S. Computer Science",
          school: "Texas A&M University",
          start_date: 1.year.from_now.strftime('%Y-%m-%d'), # Make sure this is <= Today
          end_date: 1.year.ago.strftime('%Y-%m-%d'),   # Make sure this is >= Today
          description: "Minor in Cybersecurity"
        }
      }
      expect(flash[:error]).to eq "Failed to add education."
      expect(response).to render_template(:add_education)
    end

    it "rejects malformed end date" do
      post :create_education, params: {
        id: user.id,
        education: {
          degree: "B.S. Computer Science",
          school: "Texas A&M University",
          start_date: 1.year.from_now.strftime('%Y-%m-%d'), # Make sure this is <= Today
          end_date: 1.year.ago.strftime('%Y-%m-%d'),   # Make sure this is >= Today
          description: "Minor in Cybersecurity"
        }
      }
      expect(flash[:error]).to eq "Failed to add education."
      expect(response).to render_template(:add_education)
    end
  end

  describe "PATH #update_experience" do
    it "rejects malformed start date" do
      patch :update_experience, params: {
        id: user.id,
        index: 0,
        experience: {
          title: "Senior Developer",
          company: "Tech Corp",
          start_date: 1.year.from_now.strftime('%Y-%m-%d'), # e.g., "2024-11-29"
          end_date: 1.year.ago.strftime('%Y-%m-%d'), # e.g., "2026-11-29"
          description: "Built amazing things."
        }
      }
      expect(response).to render_template(:edit_experience)
    end

    it "rejects malformed end date" do
      patch :update_experience, params: {
        id: user.id,
        index: 0,
        experience: {
          title: "Senior Developer",
          company: "Tech Corp",
          start_date: 1.year.ago.strftime('%Y-%m-%d'), # e.g., "2024-11-29"
          end_date: 1.year.from_now.strftime('%Y-%m-%d'), # e.g., "2026-11-29"
          description: "Built amazing things."
        }
      }
      expect(response).to render_template(:edit_experience)
    end
  end

  describe "PATCH #update_education" do
    it "rejects malformed start date" do
      post :update_education, params: {
        id: user.id,
        index: 0,
        education: {
          degree: "B.S. Computer Science",
          school: "Texas A&M University",
          start_date: 1.year.from_now.strftime('%Y-%m-%d'), # Make sure this is <= Today
          end_date: 1.year.ago.strftime('%Y-%m-%d'),   # Make sure this is >= Today
          description: "Minor in Cybersecurity"
        }
      }
      expect(response).to render_template(:edit_education)
    end

    it "rejects malformed end date" do
      post :update_education, params: {
        id: user.id,
        index: 0,
        education: {
          degree: "B.S. Computer Science",
          school: "Texas A&M University",
          start_date: 1.year.ago.strftime('%Y-%m-%d'), # Make sure this is <= Today
          end_date: 2.year.ago.strftime('%Y-%m-%d'),   # Make sure this is >= Today
          description: "Minor in Cybersecurity"
        }
      }
      expect(response).to render_template(:edit_education)
    end
  end

  describe "PATCH #user" do
    it "does not trigger password change if user does not provide previous password" do
      patch :update, params: {
        id: user.id, # Required to find the user
        user: {
          first_name: "New Name",
          last_name: "New Last Name",
          headline: "Software Engineer at Google",
          linkedin_url: "https://linkedin.com/in/new-url"
        }
      }
      expect(response).to redirect_to(@user)
    end

    it "rejects when user does not provide previous password" do
      patch :update, params: {
        id: user.id, # Required to find the user
        user: {
          first_name: "New Name",
          last_name: "New Last Name",
          headline: "Software Engineer at Google",
          linkedin_url: "https://linkedin.com/in/new-url",
          old_password: "",
          password: "1234567",
          password_confirmation: "1234567"
        }
      }
      expect(flash[:error]).to eq("Old password is incorrect")
      expect(response).to render_template(:edit)
    end

    it "rejects when user provides incorrect previous password" do
      patch :update, params: {
        id: user.id, # Required to find the user
        user: {
          first_name: "New Name",
          last_name: "New Last Name",
          headline: "Software Engineer at Google",
          linkedin_url: "https://linkedin.com/in/new-url",
          old_password: "1234567",
          password: "1234567",
          password_confirmation: "1234567"
        }
      }
      expect(flash[:error]).to eq("Old password is incorrect")
      expect(response).to render_template(:edit)
    end
  end
end
