require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  render_views
  # Assuming you are using Devise or a similar auth helper
  let(:user) { create(:user, email: "alice.yi@tamu.edu", password: "123456") }

  # Create a base post that we will try to match against
  # We use let! (bang) so these are created in the DB before the get request
  let!(:matching_post) { create(:referral_post,
    user: :user,
    company_name: "Google",
    job_title: "Senior Software Engineer",
    department: "Engineering",
    location: "Remote",
    job_level: "Senior Level",
    employment_type: "Full-time",
    status: 0, # Assuming 0 is active/open
    created_at: 1.hour.ago
  )}

  let!(:other_post) { create(:referral_post,
    user: :user,
    company_name: "Amazon",
    job_title: "Sales Associate",
    department: "Sales",
    location: "On-site",
    job_level: "Entry Level",
    employment_type: "Part-time",
    status: 1, # Assuming 1 is closed/draft
    created_at: 10.days.ago
  )}

  before do
    # Log the user in before every test
    sign_in user
  end

  describe "GET #index" do
    context "without filters" do
      it "returns a success response" do
        get :index
        expect(response).to be_successful
      end

      it "assigns all posts to @all_referrals" do
        get :index
        expect(assigns(:all_referrals)).to include(matching_post, other_post)
      end
    end

    describe "Filtering" do
      context "by company_name" do
        it "filters by exact match (case insensitive)" do
          get :index, params: { company_name: "google" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end

        it "filters by partial match" do
          get :index, params: { company_name: "Goo" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by job_title" do
        it "filters by partial match" do
          get :index, params: { job_title: "Engineer" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by department" do
        it "filters by partial match" do
          get :index, params: { department: "Eng" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by location" do
        it "filters by exact location" do
          get :index, params: { location: "Remote" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by job_level" do
        it "filters by job level" do
          get :index, params: { job_level: "Senior Level" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by employment_type" do
        it "filters by employment type" do
          get :index, params: { employment_type: "Full-time" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by status" do
        it "filters by status integer/string" do
          # Assuming param passed is "0" for the first enum status
          get :index, params: { status: 0 }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(other_post)
        end
      end

      context "by created_since (Date Range)" do
        it "includes posts created within the timeframe" do
          # matching_post is 1 hour ago
          get :index, params: { created_since: "24 hours" }
          expect(assigns(:all_referrals)).to include(matching_post)
        end

        it "excludes posts created outside the timeframe" do
          # other_post is 10 days ago
          get :index, params: { created_since: "7 days" }
          expect(assigns(:all_referrals)).not_to include(other_post)
        end

        it "includes older posts if the range is large enough" do
          # other_post is 10 days ago, range is 30 days
          get :index, params: { created_since: "30 days" }
          expect(assigns(:all_referrals)).to include(other_post)
        end
      end

      context "by username" do
        let(:target_user) { create(:user, username: "TargetUser") }
        let!(:user_post) { create(:referral_post, user: target_user) }

        it "filters by user username" do
          get :index, params: { username: "TargetUser" }
          expect(assigns(:all_referrals)).to include(user_post)
          expect(assigns(:all_referrals)).not_to include(matching_post)
        end
      end

      context "with combined filters" do
        it "returns posts that match ALL criteria" do
          # Match Company but wrong Location
          get :index, params: { company_name: "Google", location: "On-site" }
          expect(assigns(:all_referrals)).to be_empty

          # Match Company AND Location
          get :index, params: { company_name: "Google", location: "Remote" }
          expect(assigns(:all_referrals)).to include(matching_post)
        end
      end
    end
  end
end
