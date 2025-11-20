Given("a user exists with email {string} and token {string}") do |email, token|
  @user = User.create!(
    first_name: "Test",
    last_name: "User",
    email: email,
    password: "password",
    password_confirmation: "password",
    tamu_verification_token: token,
    is_tamu_verified: false
  )
  # We need to manually update the token because has_secure_token might generate one on create
  @user.update_column(:tamu_verification_token, token)
end

When("I visit the TAMU verification link with token {string}") do |token|
  visit verify_tamu_path(token: token)
end

Then("the user {string} should be TAMU verified") do |email|
  user = User.find_by(email: email)
  expect(user.is_tamu_verified).to be true
end

Then("the user {string} should not be TAMU verified") do |email|
  user = User.find_by(email: email)
  expect(user.is_tamu_verified).to be false
end

Given("a company verification exists for {string} with token {string}") do |company_name, token|
  # Ensure we have a user to attach this to
  step "I am logged in" unless @user

  @cv = @user.company_verifications.create!(
    company_name: company_name,
    company_email: "test@#{company_name.downcase}.com",
    is_verified: false
  )
  @cv.update_column(:verification_token, token)
end

When("I visit the company verification link with token {string}") do |token|
  visit verify_company_path(token: token)
end

Then("the company verification for {string} should be verified") do |company_name|
  cv = CompanyVerification.find_by(company_name: company_name)
  expect(cv.is_verified).to be true
end

Then("the company verification for {string} should not be verified") do |company_name|
  cv = CompanyVerification.find_by(company_name: company_name)
  expect(cv.is_verified).to be false
end
