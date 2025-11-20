Given("I am on my profile page") do
  visit user_path(@user)
end

When("I click {string}") do |button_text|
  click_link_or_button button_text
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

Given("I have an existing experience") do
  @user.experiences_data << {
    "title" => "Junior Dev",
    "company" => "Startup",
    "start_date" => "2018-01-01",
    "end_date" => "2019-01-01"
  }
  @user.save!
end

Given("I have an existing education") do
  @user.educations_data << {
    "degree" => "BA",
    "school" => "University",
    "start_date" => "2012-09-01",
    "end_date" => "2016-05-01"
  }
  @user.save!
end

When("I click {string} within the experience section") do |link_text|
  within("#experiences") do
    click_link_or_button link_text
  end
end

When("I click {string} within the education section") do |link_text|
  within("#education") do
    click_link_or_button link_text
  end
end
