require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  render_views
  # Assuming you are using Devise or a similar auth helper
  User.destroy_all
  CompanyVerification.destroy_all
  ReferralPost.destroy_all
  let!(:user) { User.create!(first_name: "Alice", last_name: "Yi", email: "alice.yi@tamu.edu", password: "123456") }
  let!(:user_bob) { User.create!(first_name: "Bob", last_name: "Lai", email: "bob.lai@tamu.edu", password: "123456") }
  let!(:verification_google) { CompanyVerification.create!(user: user, company_email: "alice.yi@google.com", company_name: "Google", is_verified: true) }
  let!(:verification_amazon) { CompanyVerification.create!(user: user, company_email: "alice.yi@amazon.com", company_name: "Amazon", is_verified: true) }
  let!(:verification_samsung) { CompanyVerification.create!(user: user_bob, company_email: "bob.lai@samsung.com", company_name: "Samsung", is_verified: true) }

  # Create a base post that we will try to match against
  # We use let! (bang) so these are created in the DB before the get request
  let!(:matching_post) { ReferralPost.create(user: user,
    title: "Software Engineer Position",
    company_verification: verification_google,
    company_name: "Google",
    job_title: "Senior Software Engineer",
    department: "Engineering",
    location: "Remote",
    job_level: "Senior Level",
    employment_type: "Full-time",
    status: :active,
    created_at: 1.hour.ago
  )}

  let!(:other_post) { ReferralPost.create(user: user,
    title: "Sales Associate Position",
    company_verification: verification_amazon,
    company_name: "Amazon",
    job_title: "Sales Associate",
    department: "Sales",
    location: "On-site",
    job_level: "Entry Level",
    employment_type: "Part-time",
    status: :active,
    created_at: 10.days.ago
  )}

  let!(:bob_post) { ReferralPost.create(user: user_bob,
    title: "Samsung Marketing Role",
    company_verification: verification_samsung,
    company_name: "Samsung",
    job_title: "Sales Associate",
    department: "Sales",
    location: "On-site",
    job_level: "Entry Level",
    employment_type: "Part-time",
    status: :active,
    created_at: 10.days.ago
  )}

  let!(:bob_post_closed) { ReferralPost.create(user: user_bob,
    title: "Samsung Data Science Role",
    company_verification: verification_samsung,
    company_name: "Samsung",
    job_title: "Data Scientist",
    department: "Sales",
    location: "On-site",
    job_level: "Entry Level",
    employment_type: "Part-time",
    status: :closed,
    created_at: 10.days.ago
  )}

  before do
    # Log the user in before every test
    session[:user_id] = user.id
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
        expect(assigns(:all_referrals)).not_to include(bob_post_closed)
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
        it "filters by status active" do
          # Assuming param passed is "0" for the first enum status
          get :index, params: { status: "Active" }
          expect(assigns(:all_referrals)).to include(matching_post)
          expect(assigns(:all_referrals)).not_to include(bob_post_closed)
        end
        it "filters by status closed" do
          # Assuming param passed is "0" for the first enum status
          get :index, params: { status: "Closed" }
          expect(assigns(:all_referrals)).to include(bob_post_closed)
          expect(assigns(:all_referrals)).not_to include(matching_post)
        end

        it "filters by status paused" do
          # Assuming param passed is "0" for the first enum status
          get :index, params: { status: "Paused" }
          expect(assigns(:all_referrals).size).to eq(0)
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

        it "excludes posts created outside the timeframe" do
          # other_post is 10 days ago
          get :index, params: { created_since: "90 days" }
          expect(assigns(:all_referrals)).to include(other_post)
        end

        it "includes older posts if the range is large enough" do
          # other_post is 10 days ago, range is 180 days
          get :index, params: { created_since: "180 days" }
          expect(assigns(:all_referrals)).to include(other_post)
        end

        it "includes older posts if the range is large enough" do
          # other_post is 10 days ago, range is 180 days
          get :index, params: { created_since: "1 year" }
          expect(assigns(:all_referrals)).to include(other_post)
        end

        it "includes older posts if the range is large enough" do
          # other_post is 10 days ago, range is 180 days
          get :index, params: { created_since: "9 days" }
          expect(assigns(:all_referrals)).to include(other_post)
        end
      end

      context "by username" do
        it "filters by user username" do
          get :index, params: { username: "Bob" }
          expect(assigns(:all_referrals)).to include(bob_post)
          expect(assigns(:all_referrals)).not_to include(matching_post, other_post)
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
