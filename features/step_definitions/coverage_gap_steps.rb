Given('I have a resume attached') do
  @user.resume.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_resume.pdf')), filename: 'sample_resume.pdf', content_type: 'application/pdf')
end

When('I check "Remove resume"') do
  check 'remove_resume'
end





When('I visit the add education page') do
  visit add_education_user_path(@user)
end

Given('I force company verification save to fail') do
  allow_any_instance_of(CompanyVerification).to receive(:save).and_return(false)
end



When('I visit the verification link with token {string}') do |token|
  visit verify_company_verification_path(@cv, token: token)
end

Given('I have an experience entry') do
  @user.experiences_data = [{ "title" => "Dev", "company" => "Test", "start_date" => "2020-01-01", "end_date" => "2021-01-01", "description" => "Desc" }]
  @user.save!
end

Given('I have an education entry') do
  @user.educations_data = [{ "degree" => "BS", "school" => "TAMU", "start_date" => "2020-01-01", "end_date" => "2024-01-01", "description" => "Desc" }]
  @user.save!
end

Given('I force user save to fail') do
  allow_any_instance_of(User).to receive(:save).and_return(false)
end

When('I delete the experience entry') do
  visit edit_user_path(@user)
  # Assuming there's a delete button/link for the experience. 
  # We might need to be more specific if there are multiple.
  # Based on views, it's a button_to "Delete"
  within("#experience-section") do
    click_button "Delete"
  end
end

When('I delete the education entry') do
  visit edit_user_path(@user)
  within("#education-section") do
    click_button "Delete"
  end
end

Given('I have a referral post titled {string}') do |title|
  # Create verification first
  cv = @user.company_verifications.create!(
    company_name: "My Company",
    company_email: "recruiter@mycompany.com",
    is_verified: true
  )
  @post = @user.referral_posts.create!(
    company_verification: cv,
    title: title,
    job_title: "Software Engineer",
    company_name: "My Company",
    status: :active
  )
end

When('I click "Delete" for the post {string}') do |title|
  visit referral_posts_path(mine: "true")

  
  # Find the card containing the title
  card = find('.card', text: title)
  within(card) do
    click_button "Delete"
  end
end

Given('another user has a referral post titled {string}') do |title|
  other_user = User.create!(
    first_name: "Other",
    last_name: "User",
    email: "other@tamu.edu",
    password: "password",
    password_confirmation: "password"
  )
  cv = other_user.company_verifications.create!(
    company_name: "Other Company",
    company_email: "recruiter@othercompany.com",
    is_verified: true
  )
  @other_post = other_user.referral_posts.create!(
    company_verification: cv,
    title: title,
    job_title: "Product Manager",
    company_name: "Other Company",
    status: :active
  )
end

When('I try to edit the post {string}') do |title|
  visit edit_referral_post_path(@other_post)
end

Then('I should be on the login page') do
  expect(page.current_path).to eq(new_user_path)
end

When('I visit the referral posts page') do
  visit referral_posts_path
end
When('I visit my referral posts page') do
  visit referral_posts_path(mine: "true")
end

When('I search for {string}') do |query|
  fill_in "query", with: query
  click_button "Search"
end

Given('another user has a conversation') do
  other_user = User.create!(
    first_name: "Other",
    last_name: "User",
    email: "other@tamu.edu",
    password: "password",
    password_confirmation: "password"
  )
  recipient = User.create!(
    first_name: "Recipient",
    last_name: "User",
    email: "recipient@tamu.edu",
    password: "password",
    password_confirmation: "password"
  )
  @other_conversation = Conversation.create!(
    sender: other_user,
    recipient: recipient,
    subject: "Hello"
  )
end

When('I try to delete the conversation') do
  # Manually send DELETE request since I can't see the button
  page.driver.submit :delete, conversation_path(@other_conversation), {}
end

Given('I have a referral request for {string}') do |post_title|
  post = ReferralPost.find_by(title: post_title)
  @request = post.referral_requests.create!(
    user: @user,
    status: :pending,
    submitted_data: { "why" => "I am good" }
  )
end

When('I update the request status to {string}') do |status|
  # Use the route helper to update status
  page.driver.submit :patch, update_referral_request_status_path(@request), { status: status }
end

Then('the post {string} should be active') do |title|
  post = ReferralPost.find_by(title: title)
  expect(post.status).to eq("active")
end

Given('I force request status update to fail') do
  allow_any_instance_of(ReferralRequest).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(ReferralRequest.new))
end

Given('I submit a referral request with array data') do
  # Manually post to create request with array submitted_data
  # This will be parsed as { "submitted_data" => ["one", "two"] }
  page.driver.post referral_post_referral_requests_path(@post), {
    submitted_data: ["one", "two"]
  }
  # Follow redirect
  visit referral_post_path(@post)
end
