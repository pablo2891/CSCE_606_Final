require "rails_helper"

RSpec.describe "TestCoverageController", type: :request do
  it "returns helper harness result" do
    allow_any_instance_of(ApplicationController).to receive(:require_login).and_return(true)
    get "/test/coverage_helper"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("true")
  end
end
