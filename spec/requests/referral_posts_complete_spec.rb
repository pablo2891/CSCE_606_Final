require 'rails_helper'

RSpec.describe "ReferralPosts Complete Coverage", type: :request do
  let!(:user) do
    User.create!(
      email: "user@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Test",
      last_name: "User"
    )
  end

  let!(:other_user) do
    User.create!(
      email: "other@tamu.edu",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Other",
      last_name: "User"
    )
  end

  let!(:company_verification) do
    user.company_verifications.create!(
      company_name: "Google",
      company_email: "user@google.com",
      is_verified: true
    )
  end

  let!(:referral_post) do
    user.referral_posts.create!(
      title: "Senior Engineer",
      job_title: "Engineer",
      company_name: "Google",
      department: "Engineering",
      location: "Remote",
      job_level: "Senior",
      employment_type: "Full-time",
      why_referring: "Great team",
      company_verification: company_verification,
      status: :active,
      questions: [ "Why?", "Experience?" ]
    )
  end

  before do
    post session_path, params: { user: { email: user.email, password: "password123" } }
  end

  describe "GET /referral_posts/:id/edit" do
    it "renders edit form for owner" do
      get edit_referral_post_path(referral_post)
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Referral Post")
    end

    it "redirects non-owner" do
      delete session_path
      post session_path, params: { user: { email: other_user.email, password: "password123" } }

      get edit_referral_post_path(referral_post)
      expect(response).to redirect_to(referral_posts_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Unauthorized")
    end
  end

  describe "PATCH /referral_posts/:id" do
    it "updates post successfully" do
      patch referral_post_path(referral_post), params: {
        referral_post: {
          title: "Updated Title",
          job_title: "Senior Engineer",
          company_name: "Google",
          questions: [ "New question 1", "New question 2", "" ]
        }
      }

      referral_post.reload
      expect(referral_post.title).to eq("Updated Title")
      expect(referral_post.questions.length).to eq(2)

      expect(response).to redirect_to(referral_post_path(referral_post))
      follow_redirect!
      expect(flash[:notice]).to eq("Referral post updated!")
    end

    it "strips blank questions on update" do
      patch referral_post_path(referral_post), params: {
        referral_post: {
          title: "Updated",
          job_title: "Engineer",
          company_name: "Google",
          questions: [ "Q1", "", "Q2", "   ", "Q3" ]
        }
      }

      referral_post.reload
      expect(referral_post.questions).to eq([ "Q1", "Q2", "Q3" ])
    end

    it "renders edit on update failure" do
      # Mock to prevent actual render attempt
      allow_any_instance_of(ReferralPost).to receive(:update).and_return(false)
      allow_any_instance_of(ReferralPost).to receive(:errors).and_return(
          double(full_messages: [ "Title can't be blank" ])
      )
      patch referral_post_path(referral_post), params: {
          referral_post: {
          title: "",  # Invalid - title is required
          job_title: "Engineer",
          company_name: "Google"
          }
      }
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Referral Post")
    end

    it "prevents non-owner from updating" do
      delete session_path
      post session_path, params: { user: { email: other_user.email, password: "password123" } }

      patch referral_post_path(referral_post), params: {
        referral_post: { title: "Hacked" }
      }

      referral_post.reload
      expect(referral_post.title).not_to eq("Hacked")
      expect(response).to redirect_to(referral_posts_path)
    end
  end

  describe "DELETE /referral_posts/:id" do
    it "deletes post as owner" do
      expect {
        delete referral_post_path(referral_post)
      }.to change(ReferralPost, :count).by(-1)

      expect(response).to redirect_to(referral_posts_path)
      follow_redirect!
      expect(flash[:notice]).to eq("Referral post deleted.")
    end

    it "prevents non-owner from deleting" do
      delete session_path
      post session_path, params: { user: { email: other_user.email, password: "password123" } }

      expect {
        delete referral_post_path(referral_post)
      }.not_to change(ReferralPost, :count)

      expect(response).to redirect_to(referral_posts_path)
    end
  end

  describe "GET /referral_posts" do
    it "shows only active posts" do
      closed_post = user.referral_posts.create!(
        title: "Closed Post",
        job_title: "Dev",
        company_name: "Google",
        company_verification: company_verification,
        status: :closed
      )

      get referral_posts_path, params: { mine: "true" }

      expect(response.body).to include("Senior Engineer")
      expect(response.body).not_to include("Closed Post")
    end
  end

  describe "POST /referral_posts with invalid verification" do
    it "rejects post without verified company" do
      unverified = user.company_verifications.create!(
        company_name: "Facebook",
        company_email: "user@facebook.com",
        is_verified: false
      )

      post referral_posts_path, params: {
        referral_post: {
          title: "Test Post",
          job_title: "Engineer",
          company_name: "Facebook"
        }
      }

      expect(flash[:error]).to eq("You must pick one of your verified companies.")
      expect(response).to render_template(:new)
    end
  end

  describe "RecordNotFound handling" do
    it "handles deleted post gracefully" do
      get referral_post_path(id: 99999)
      expect(response).to redirect_to(dashboard_path)
      follow_redirect!
      expect(flash[:alert]).to eq("Referral post may have been removed or you may not have access.")
    end
  end
end
