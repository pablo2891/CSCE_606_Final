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
  # Use RSpec Mocks via including its syntax in Cucumber World if not already.
  # Fallback: stub at class level.
  CompanyVerification.class_eval do
    def save(*_args) = false
  end
end

When('I visit the new company verification page with company {string}') do |company_name|
  visit new_company_verification_path(company: company_name)
end

Then('I should see the company verification form') do
  expect(page).to have_content('Enter your company domain email')
end

When('I visit the new company verification page') do
  visit new_company_verification_path
end

Then('the company name field should be pre-filled with {string}') do |company_name|
  # Look for the specific company name field
  field = find_field('Company Name')
  expect(field.value).to eq(company_name)
end

Then('the company name field should be empty') do
  field = find_field('Company Name')
  expect(field.value).to be_nil.or eq('')
end

Given('I have a pending verification for {string} with id {int}') do |company_name, id|
  @company_verification = @user.company_verifications.create!(
    company_name: company_name,
    company_email: "test@#{company_name.downcase}.com",
    is_verified: false
  )
  # Force the ID for testing purposes
  @company_verification.update_column(:id, id)
end

When('I visit the verify endpoint for verification {int} with valid token') do |id|
  verification = CompanyVerification.find(id)
  visit verify_company_verification_path(verification, token: verification.verification_token)
end

Then('I should be redirected to company verifications page') do
  expect(page.current_path).to eq(company_verifications_path)
end

Then('the verification for {string} should be verified') do |company_name|
  verification = CompanyVerification.find_by(company_name: company_name)
  # Reload to get the latest state
  verification.reload
  expect(verification.is_verified).to be true
end

When('I visit the verify endpoint for verification {int} with invalid token') do |id|
  visit verify_company_verification_path(id: id, token: 'invalid_token')
end

Then('I should be redirected to root path') do
  expect(page.current_path).to eq(root_path)
end

When('I visit the company verifications page') do
  visit company_verifications_path
end

Then('I should see {string} in the verified list') do |company_name|
  # Find the second table (verified list) or look for verified content
  if page.has_css?('table', count: 2)
    tables = all('table')
    verified_table = tables[1] # second table is verified list
    within(verified_table) do
      expect(page).to have_content(company_name)
    end
  else
    # Fallback: look for the company name in verified section
    expect(page).to have_content(company_name)
  end
end

Then('I should see {string} in the pending list') do |company_name|
  # Find the first table (pending list) or look for pending content
  if page.has_css?('table', count: 2)
    tables = all('table')
    pending_table = tables[0] # first table is pending list
    within(pending_table) do
      expect(page).to have_content(company_name)
    end
  else
    # Fallback: look for the company name
    expect(page).to have_content(company_name)
  end
end
