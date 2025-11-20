Given("I am on the profile page") do
  visit user_path(@user)
end

Given("I have an existing experience at {string}") do |company_name|
  @user.experiences_data << {
    "title" => "Software Engineer",
    "company" => company_name,
    "start_date" => "2022-01-01",
    "description" => "Working hard"
  }
  @user.save!
end

When("I click {string} within the {string} experience section") do |link_text, company_name|
  # Find the experience card that contains the company name
  # We use match: :first to pick the first one if duplicates exist, or refine by title if needed
  experience_div = find(:xpath, "(//div[contains(., '#{company_name}')][contains(@class, 'border-tamu-gray-300')])[1]")
  
  within(experience_div) do
    click_link link_text
  end
end


Then("I should see {string} within the {string} experience section") do |text, company_name|
  # Find the experience card that contains the company name
  experience_div = find(:xpath, "(//div[contains(., '#{company_name}')][contains(@class, 'border-tamu-gray-300')])[1]")
  within(experience_div) do
    expect(page).to have_content(text)
  end
end

Given("I have a pending verification for {string}") do |company_name|
  @user.company_verifications.create!(
    company_name: company_name,
    company_email: "me@#{company_name.downcase}.com",
    is_verified: false
  )
end

Given("I am on the company verifications page") do
  visit company_verifications_path
end

When("I click {string} for {string}") do |link_text, company_name|
  # Find the table row that contains the company name
  row = find("tr", text: company_name)
  within(row) do
    click_button link_text
  end
end

Then("I should not see {string} in the pending list") do |company_name|
  expect(page).not_to have_content(company_name)
end

Given("the system fails to save company verifications") do
  allow_any_instance_of(CompanyVerification).to receive(:save).and_return(false)
end
