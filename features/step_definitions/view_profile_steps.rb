Given("I am logged in as a user with first name {string} and last name {string}") do |first, last|
  @user = User.create!(
    first_name: first,
    last_name: last,
    email: "#{first.downcase}.#{last.downcase}@tamu.edu",
    password: "password123",
    experiences_data: [
      {
        "title" => "Software Intern",
        "company" => "TechCorp",
        "start_date" => "2023-05-01",
        "end_date" => "2023-08-01",
        "description" => "Worked on web applications."
      }
    ],
    educations_data: [
      {
        "degree" => "BS Computer Engineering",
        "school" => "Texas A&M University",
        "start_date" => "2021-08-01",
        "end_date" => "2025-05-01",
        "description" => "Studying computer engineering."
      }
    ]
  )

  visit new_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Login"
end


When("I visit my profile page") do
  visit user_path(@user)
end

Then("I should see my email address") do
  expect(page).to have_content(@user.email)
end

Then("I should see my experiences") do
  @user.experiences_data.each do |exp|
    expect(page).to have_content(exp["company"])
    expect(page).to have_content(exp["title"])
  end
end

Then("I should see my education entries") do
  @user.educations_data.each do |ed|
    expect(page).to have_content(ed["school"])
    expect(page).to have_content(ed["degree"])
  end
end

Given("another user exists with first name {string} and last name {string}") do |first, last|
  @other_user = User.create!(
    first_name: first,
    last_name: last,
    email: "#{first.downcase}.#{last.downcase}@tamu.edu",
    password: "password123",
    experiences_data: [
      {
        "title" => "Backend Engineer",
        "company" => "OpenAI",
        "start_date" => "2022-01-01",
        "end_date" => nil,
        "description" => "Works on advanced AI systems."
      }
    ],
    educations_data: [
      {
        "degree" => "BS Computer Science",
        "school" => "MIT",
        "start_date" => "2018-08-01",
        "end_date" => "2022-05-01",
        "description" => "Studied CS."
      }
    ]
  )
end

When("I visit the profile page for {string}") do |full_name|
  first, last = full_name.split(" ")
  user = User.find_by(first_name: first, last_name: last)
  visit user_path(user)
end

Then("I should not see an Edit Profile button") do
  expect(page).not_to have_link("Edit Profile")
end

When("I visit the profile page for a user with ID {string}") do |id|
  visit user_path(id)
end

Then("I should see an error message {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should be redirected to {string}") do |path|
  expect(current_path).to eq(path)
end

When("I visit the profile page of any user") do
  other_user = User.create!(
    first_name: "Other",
    last_name: "User",
    email: "other.user@tamu.edu",
    password: "password123",
    password_confirmation: "password123"
  )

  visit user_path(other_user)
end
