Given("I have a verified company {string}") do |company_name|
  # Create a verification for the current user
  @user.company_verifications.create!(
    company_name: company_name,
    company_email: "recruiter@#{company_name.downcase.gsub(/\s+/, "")}.com",
    is_verified: true
  )
end

Given("I am on the new referral post page") do
  visit new_referral_post_path
end

When("I select {string} from {string}") do |option, field|
  select option, from: field
end

Then("I should be redirected to the referral posts page") do
  expect(page.current_path).to eq(referral_posts_path)
end

Given("there is a referral post for {string}") do |company_name|
  # Create a post for the CURRENT user so they can receive requests
  cv = @user.company_verifications.find_by(company_name: company_name)
  if cv.nil?
    cv = @user.company_verifications.create!(
      company_name: company_name,
      company_email: "recruiter@#{company_name.downcase.gsub(/\s+/, "")}.com",
      is_verified: true
    )
  end

  ReferralPost.create!(
    user: @user,
    company_verification: cv,
    title: "Job at #{company_name}",
    job_title: "Software Engineer",
    company_name: company_name,
    status: :active
  )
end

Given("I have already requested a referral for this post") do
  post = ReferralPost.last
  post.referral_requests.create!(user: @user, status: :pending)
end

Given("I am on the referral posts page") do
  visit referral_posts_path
end

When("I force a duplicate referral request") do
  post = ReferralPost.last
  # Direct POST to exercise controller else branch when uniqueness validation fails
  page.driver.post referral_post_referral_requests_path(post)
  # Follow redirect
  visit referral_posts_path
end

Then('I should be redirected to the created referral post') do
  # Check that we're on a referral post show page (path like /referral_posts/:id)
  expect(page.current_path).to match(/\/referral_posts\/\d+/)
  # Also verify we see the success message
  expect(page).to have_content("Referral post created!")
end

Then('I should see the referral request status as {string}') do |status|
  request = ReferralRequest.find_by(user: @user)
  expect(request).to be_present
  expect(request.status).to eq(status.downcase)
  visit dashboard_path
end

Given("I am viewing referral posts as a different user") do
  first_name, last_name = "Jane", "Doe"

  @user = User.find_or_create_by!(first_name: first_name, last_name: last_name) do |u|
    u.email = "#{first_name.downcase}.#{last_name.downcase}@tamu.edu"
    u.password = "password"
    u.password_confirmation = "password"
  end

  # Direct login via session
  page.set_rack_session(user_id: @user.id)

  # Visit referral posts page
  visit referral_posts_path
  expect(page).to have_current_path(referral_posts_path)
end
