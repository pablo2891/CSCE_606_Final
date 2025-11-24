require 'rails_helper'

RSpec.describe "dashboard/index.html.erb", type: :view do
  it "renders the dashboard index" do
    assign(:received_requests, [])
    assign(:sent_requests, [])
    render template: 'dashboard/index'
    expect(rendered).to be_present
  end
end
