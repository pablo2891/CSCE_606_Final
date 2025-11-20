When("I visit my edit profile page") do
  visit edit_user_path(@user)
end

When("I visit the edit profile page for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit edit_user_path(user)
end

When("I fill in the profile form with:") do |table|
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end
end

When("I press {string}") do |button|
  click_button button
end

Then("I should find my resume link {string} on my profile page") do |link|
  expect(page).to have_css("a[href='http://example.com/new_resume.pdf']")
end

Then("I should be on the edit profile page") do
  expect(page).to have_current_path(edit_user_path(@user))
end

Then("I should be on the profile page for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  expect(page).to have_current_path(user_path(user))
end

Then("I should be redirected to the profile page for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  expect(page).to have_current_path(user_path(user))
end
