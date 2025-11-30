require 'rails_helper'

RSpec.describe "dashboard/index.html.erb", type: :view do
  # before :all do
  #   # Create 2 users: Alice Yi and Bob Lai
  #   User.destroy_all
  #   ReferralPost.destroy_all
  #   ReferralRequest.destroy_all
  #   @alice = FactoryBot.create(:user,
  #     email: "alice.yi@tamu.edu",
  #     first_name: "Alice",
  #     last_name: "Yi"
  #   )
  #   @bob = FactoryBot.create(:user,
  #     email: "bob.lai@tamu.edu",
  #     first_name: "Bob",
  #     last_name: "Lai"
  #   )

  #   # Create company verifications for each user (required for referral posts)
  #   @alice_verification = FactoryBot.create(:company_verification,
  #     user: @alice,
  #     company_name: "Alice Corp",
  #     company_email: "alice@alicecorp.com"
  #   )
  #   @bob_verification = FactoryBot.create(:company_verification,
  #     user: @bob,
  #     company_name: "Bob Inc",
  #     company_email: "bob@bobinc.com"
  #   )

  #   # Create 2 testing referral posts, one from Alice Yi, another from Bob Lai
  #   @alice_post = FactoryBot.create(:referral_post,
  #     user: @alice,
  #     company_verification: @alice_verification,
  #     title: "Senior Software Engineer at Alice Corp",
  #     company_name: "Alice Corp",
  #     job_title: "Senior Software Engineer"
  #   )
  #   @bob_post = FactoryBot.create(:referral_post,
  #     user: @bob,
  #     company_verification: @bob_verification,
  #     title: "Software Engineer at Bob Inc",
  #     company_name: "Bob Inc",
  #     job_title: "Software Engineer"
  #   )

  #   # Create 2 testing referral requests, one from Alice Yi to Bob Lai's Referral Post, and one from Bob Lai to Alice Yi's referral post
  #   @alice_request = FactoryBot.create(:referral_request,
  #     user: @alice,
  #     referral_post: @bob_post,
  #     status: :pending
  #   )
  #   @bob_request = FactoryBot.create(:referral_request,
  #     user: @bob,
  #     referral_post: @alice_post,
  #     status: :pending
  #   )
  # end

  it "renders the dashboard index" do
    assign(:received_requests, [])
    assign(:sent_requests, [])
    assign(:all_referrals, [])
    # 3. Assign DROPDOWN OPTIONS (CRITICAL: This fixes your specific error)
    # The view iterates over these, so they CANNOT be nil.
    assign(:location_options, [ "Remote", "On-site", "Hybrid" ])
    assign(:job_level_options, [ "Internship", "Entry Level", "Mid Level", "Senior Level", "Executive" ])
    assign(:employment_type_options, [ "Full-time", "Part-time", "Contract", "Internship" ])
    assign(:status_options, [ "Active", "Paused", "Closed" ])
    assign(:date_ranges, [ "24 hours", "7 days", "30 days", "90 days" ])
    # 4. Assign FILTER INPUTS
    # These can be nil, but it's safer to assign them to avoid warnings
    assign(:selected_company, nil)
    assign(:selected_job_title, nil)
    assign(:selected_department, nil)
    assign(:selected_user, nil)
    assign(:selected_location, nil)
    assign(:selected_job_level, nil)
    assign(:selected_employment_type, nil)
    assign(:selected_created_since, nil)
    render template: 'dashboard/index'

    expect(rendered).to be_present
  end

  # it "should display referral request submission" do
  #   assign(:received_requests, [ @alice_request ])
  #   assign(:sent_requests, [ @bob_request ])
  #   assign(:all_referrals, [])
  #   render template: 'dashboard/index'
  #   expect(rendered).to match /Alice/
  # end
end
