class TestCoverageController < ApplicationController
  # Only used in test environment via routes guard
  include ApplicationHelper

  def helper_harness
    # call company_match? to exercise normalization logic
    result = company_match?("Google", " google ")
    render plain: result.to_s
  end
end
