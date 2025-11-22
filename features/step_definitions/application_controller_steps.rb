When("I visit a protected route") do
  # Use a route that requires login
  visit dashboard_path
end

Then("I should see the protected content") do
  expect(page).to have_current_path(dashboard_path)
end

When("I check current_user") do
  # This is tested via controller behavior
  visit dashboard_path
  @current_user_check = page.has_content?(@user.full_name)
end

Then("it should return my user object") do
  expect(@current_user_check).to be true
end

When("I check logged_in?") do
  # Test via attempting to access protected route
  visit dashboard_path
  @logged_in_result = page.current_path == dashboard_path
end

Then("it should return true") do
  expect(@logged_in_result).to be true
end

Then("it should return false") do
  expect(@logged_in_result).to be false
end
