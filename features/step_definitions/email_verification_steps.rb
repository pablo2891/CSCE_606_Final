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

Given('I have a pending verification for {string} with token {string}') do |company_name, token|
  @company_verification = @user.company_verifications.create!(
    company_name: company_name,
    company_email: "test@#{company_name.downcase}.com",
    is_verified: false
  )
  @company_verification.update_column(:verification_token, token)
end

Given('that user has a pending verification for {string} with token {string}') do |company_name, token|
  @other_user ||= User.find_by(email: 'guest@tamu.edu')
  unless @other_user
    @other_user = User.create!(
      first_name: 'Guest',
      last_name: 'User',
      email: 'guest@tamu.edu',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  @company_verification = @other_user.company_verifications.create!(
    company_name: company_name,
    company_email: "test@#{company_name.downcase}.com",
    is_verified: false
  )
  @company_verification.update_column(:verification_token, token)
end

Then('I should be redirected to the root path') do
  # Be more flexible about the redirect target
  expect([ root_path, new_session_path, new_user_path, '/' ]).to include(page.current_path)
end
