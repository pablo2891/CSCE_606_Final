Then('I should be redirected to the dashboard page') do
  expect(page).to have_current_path(dashboard_path)
end

When('I visit the company verification link for the last verification') do
  verification = CompanyVerification.last
  # Email verification route is GET /verify_company?token=...
  visit "/verify_company?token=#{verification.verification_token}"
end
