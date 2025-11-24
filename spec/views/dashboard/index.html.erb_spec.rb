require 'rails_helper'

RSpec.describe "dashboard/index.html.erb", type: :view do
  it "renders the dashboard index" do
    assign(:received_requests, [])
    assign(:sent_requests, [])
    assign(:all_referrals, [])
    # 3. Assign DROPDOWN OPTIONS (CRITICAL: This fixes your specific error)
    # The view iterates over these, so they CANNOT be nil.
    assign(:location_options, [ "Remote", "On-site", "Hybrid" ])
    assign(:job_level_options, [ "Internship", "Entry Level", "Mid Level", "Senior Level", "Executive" ])
    assign(:employment_type_options, [ "Full-time", "Part-time", "Contract", "Internship" ])
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
end
