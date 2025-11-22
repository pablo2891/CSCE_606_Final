Given("I am logged in as {string}") do |full_name|
  first_name, last_name = full_name.split(" ")
  @user = User.find_or_create_by!(first_name: first_name, last_name: last_name, email: "#{first_name.downcase}@tamu.edu") do |u|
    u.password = "password"
    u.password_confirmation = "password"
  end

  # Log out first
  visit '/session'
  page.driver.submit :delete, '/session', {}

  # Login as new user
  visit new_session_path

  # Fill form with correct field identifiers
  fill_in 'user[email]', with: @user.email
  fill_in 'user[password]', with: 'password'
  click_button 'Login'

  expect(page).to have_content(@user.first_name)
end

# Add an experience manually
Given("I have an experience titled {string}") do |title|
  @user.experiences_data << {
    "title" => title,
    "company" => "TAMU",
    "start_date" => "2020-01-01",
    "end_date" => "2021-01-01",
    "description" => "Worked on projects"
  }
  @user.save!
end

# Visit add experience page
When("I visit my add experience page") do
  visit add_experience_user_path(@user)
end

# Submit a new experience
When("I submit a new experience with title {string} and company {string}") do |title, company|
  visit add_experience_user_path(@user)
  fill_in "Title", with: title
  fill_in "Company", with: company
  fill_in "Start Date", with: "2020-01-01"
  fill_in "End Date", with: "2021-01-01"
  fill_in "Description", with: "Worked on projects"
  click_button "Add Experience"
end

# Edit an experience
When("I visit the edit experience page for index {int}") do |index|
  visit edit_experience_user_path(@user, index: index)
end

# Update an experience
When("I update experience index {int} with title {string}") do |index, new_title|
  visit edit_experience_user_path(@user, index: index)
  fill_in "Title", with: new_title
  click_button "Update Experience"
end

# Assertions
Then("I should be redirected to my profile") do
  expect(current_path).to eq(user_path(@user))
end

Then("I should see an alert {string}") do |alert_text|
  expect(page).to have_content(alert_text)
end

Then("I should see the experience form") do
  # Check for the heading
  expect(page).to have_content("Add Experience")

  # Check for all the form fields
  expect(page).to have_field("Title")
  expect(page).to have_field("Company")
  expect(page).to have_field("Start Date")
  expect(page).to have_field("End Date (leave blank if current)")
  expect(page).to have_field("Description")

  # Check for the submit button
  expect(page).to have_button("Add Experience")

  # Optional: check for Cancel link
  expect(page).to have_link("Cancel")
end

When("I visit the add experience page of a user with first name {string} and last name {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit add_experience_user_path(user)
end

Then("I should see the experience form with title {string}") do |title|
  expect(page).to have_field("Title", with: title)
end

Then("I should remain on the add experience page") do
  expect(page).to have_current_path(add_experience_user_path(@user))
end

When("I attempt to update Alice Smith's experience") do
  user = User.find_by(first_name: "Alice", last_name: "Smith")
  # Assuming experience is stored as an array/hash and we edit the first one:
  visit edit_experience_user_path(user, index: 0)
end

When("I visit the add education page for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit add_education_user_path(user)
end

Then("I should see the education form") do
  expect(page).to have_selector("form")
  expect(page).to have_field("Degree")
  expect(page).to have_field("School")
end

And("I fill in the education form with:") do |table|
  table.rows_hash.each do |field, value|
    # Convert "degree" → "Degree", "start_date" → "Start date"
    label = field.to_s.split("_").map(&:capitalize).join(" ")
    fill_in label, with: value
  end
end

And("I submit the education form") do
  if page.has_button?("Save")
    click_button "Save"
  elsif page.has_button?("Add Education")
    click_button "Add Education"
  elsif page.has_button?("Update Education")
    click_button "Update Education"
  else
    raise "No recognizable submit button found on the education form"
  end
end

When("I visit the edit education page for entry {int} of {string} {string}") do |idx, first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit edit_education_user_path(user, index: idx)
end

Then("I should see {string} under the {string} field") do |value, field|
  expect(page).to have_field(field, with: value)
end

When("I visit the update education page of entry {int} for {string} {string}") do |idx, first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit update_education_user_path(user, index: idx)
end
