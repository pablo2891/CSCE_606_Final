Given("I am on the signup page") do
  visit new_user_path
end

When("I fill in valid signup information") do
  fill_in "First name", with: "Test"
  fill_in "Last name", with: "User"
  fill_in "Email", with: "test_user@tamu.edu"
  fill_in "Password", with: "password"
  fill_in "Password confirmation", with: "password"
end

When("I submit the form") do
  # Check if on signup or login page
  if page.has_button?("Sign Up")
    click_button "Sign Up"
  else
    click_button "Login"
  end
end

Then("I should see a welcome message") do
  # After successful signup, user is logged in and redirected to profile
  expect(page).to have_content("Account created successfully!")
  expect(page).to have_content("Profile")
  expect(page).to have_content("Test User")
  expect(page).to have_content("Email: test_user@tamu.edu")
end

Given("I have an account") do
  @user = User.create!(
    first_name: "Test",
    last_name: "User",
    email: "test_user@tamu.edu",
    password: "password",
    password_confirmation: "password"
  )
end

Given("I am on the login page") do
  visit new_session_path
end

When("I fill in valid login credentials") do
  fill_in "Email", with: @user.email
  fill_in "Password", with: "password"
end

Then("I should see my profile page") do
  expect(page).to have_content("Test User")
  expect(page).to have_content("Email: #{@user.email}")
  expect(page).to have_content("Summary")
  expect(page).to have_content("Experiences")
  expect(page).to have_content("Education")
end

Given("I am logged in") do
  @user ||= User.create!(
    first_name: "Test",
    last_name: "User",
    email: "test_user@tamu.edu",
    password: "password",
    password_confirmation: "password"
  )

  visit new_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: "password"
  click_button "Login"

  # Ensure the profile page loaded and logout button exists
  expect(page).to have_content("Test User")
  expect(page).to have_button("Log Out")
end

When("I click logout") do
  click_button('Log Out', match: :first)
end

Then("I should see the homepage") do
  # After logout, the app redirects to login page, not root
  expect(page).to have_current_path(new_session_path)
  expect(page).to have_content("Log In")
end

When("I forget to fill in signup information") do
  fill_in "First name", with: ""
  fill_in "Last name", with: ""
  fill_in "Email", with: ""
  fill_in "Password", with: ""
  fill_in "Password confirmation", with: ""
end

Then("I should see the signup page") do
  expect(page).to have_current_path(users_path)
  expect(page).to have_content("Sign Up")
end

Then("I should see a can't be blank signup warning") do
  expect(page).to have_content("can't be blank")
end

Given("I am not logged in") do
  page.driver.submit :delete, session_path, {}
end

When("I visit a non-existent page") do
  visit "/some-totally-fake-route-#{SecureRandom.hex(4)}"
end

Then("I should be redirected to the login page") do
  expect(page.current_path).to eq(new_session_path)
end

Then('I should see {string}') do |test|
  expect(page).to have_content(test)
end

When("I fill in invalid login credentials") do
  fill_in "Email", with: "invalid-email"
  fill_in "Password", with: "invalid-password"
end

When("I visit {string}") do |path|
  visit path
end

Then("I should be redirected to my profile page") do
  expect(page.current_path).to eq(user_path(@user))
end

Then("I should not see {string}") do |content|
  expect(page).not_to have_content(content)
end
