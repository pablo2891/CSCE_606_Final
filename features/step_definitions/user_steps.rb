Then("I should see the add experience form") do
  expect(page).to have_field("experience[title]")
  expect(page).to have_field("experience[company]")
end

Then("I should see the add education form") do
  expect(page).to have_field("education[degree]")
  expect(page).to have_field("education[school]")
end

Given("the database will fail to save experiences") do
  allow_any_instance_of(User).to receive(:save).and_return(false)
end

Given("the database will fail to save educations") do
  allow_any_instance_of(User).to receive(:save).and_return(false)
end

When("I visit the add experience page for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  visit add_experience_user_path(user)
end

When("I try to create experience for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  page.driver.post create_experience_user_path(user), {
    experience: {
      title: "Hacker",
      company: "Evil Corp",
      start_date: "2020-01-01"
    }
  }
  visit user_path(user)
end

Given("{string} {string} has an experience") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  user.experiences_data << {
    "title" => "Engineer",
    "company" => "Tech Co",
    "start_date" => "2020-01-01"
  }
  user.save!
end

When("I visit the edit experience page for {string} {string} index {int}") do |first, last, index|
  user = User.find_by(first_name: first, last_name: last)
  visit edit_experience_user_path(user, index: index)
end

When("I try to update experience for {string} {string} index {int}") do |first, last, index|
  user = User.find_by(first_name: first, last_name: last)
  page.driver.patch update_experience_user_path(user, index: index), {
    experience: { title: "Hacked Title" }
  }
  visit user_path(user)
end

When("I try to create education for {string} {string}") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  page.driver.post create_education_user_path(user), {
    education: {
      degree: "BS Hacking",
      school: "Evil University"
    }
  }
  visit user_path(user)
end

Given("{string} {string} has an education") do |first, last|
  user = User.find_by(first_name: first, last_name: last)
  user.educations_data << {
    "degree" => "BS",
    "school" => "University"
  }
  user.save!
end

When("I visit the edit education page for {string} {string} index {int}") do |first, last, index|
  user = User.find_by(first_name: first, last_name: last)
  visit edit_education_user_path(user, index: index)
end

When("I try to update education for {string} {string} index {int}") do |first, last, index|
  user = User.find_by(first_name: first, last_name: last)
  page.driver.patch update_education_user_path(user, index: index), {
    education: { degree: "Hacked Degree" }
  }
  visit user_path(user)
end
