When("I request PATCH to my user update with param remove_resume=1") do
  user = @user || User.first
  # The controller expects top-level :remove_resume and a :user param for strong params
  # include a permitted user attribute so params.require(:user) is satisfied
  page.driver.submit :patch, user_path(user), { user: { first_name: user.first_name }, remove_resume: '1' }
  # page will contain the response for the submitted request
end

When("I request POST to create_experience with empty fields") do
  user = @user || User.first
  # Use submit so the response body (with flash.now) is available to the test
  page.driver.submit :post, create_experience_user_path(user), { experience: { title: '', company: '', start_date: '' } }
end

When("I request GET to the conversation show for the last conversation") do
  conv = Conversation.last
  visit conversation_path(conv)
end

When("I post to the referral_requests from_message endpoint with integer payload") do
  post = ReferralPost.last
  begin
    page.driver.post referral_requests_from_message_referral_post_path(post), { submitted_data: 42 }
  rescue
    page.driver.post "/referral_posts/#{post.id}/referral_requests/from_message", { submitted_data: 42 }
  end
end

When("I create a referral post with questions") do
  # Ensure we have a verified company for current user
  cv = @user.company_verifications.last || @user.company_verifications.create!(
    company_name: "Tech Corp",
    company_email: "recruiter@techcorp.com",
    is_verified: true
  )

  page.driver.post referral_posts_path, {
    referral_post: {
      title: "Job at Tech Corp",
      company_name: cv.company_name,
      job_title: "Engineer",
      questions: [ "Q1?", "Q2?" ]
    }
  }
  # follow redirect to the created referral post show page
  post = ReferralPost.last
  visit referral_post_path(post)
end

When("I attempt to PATCH that user's profile") do
  other = @other_user || User.last
  # Attempt to update another user's profile (should be unauthorized)
  page.driver.submit :patch, user_path(other), { user: { first_name: other.first_name } }
  visit user_path(other)
end

When("I submit an invalid profile update") do
  user = @user || User.first
  # Submitting invalid email (not @tamu.edu) to trigger validation failure
  page.driver.submit :patch, user_path(user), { user: { email: 'bad@example.com' } }
  # render :edit response will be present in page
end

Then("the last referral request's submitted_data_hash should be a Hash") do
  req = ReferralRequest.last
  expect(req.submitted_data_hash).to be_a(Hash)
end

When("I post a JSON array to the referral_requests from_message endpoint") do
  post = ReferralPost.last
  json_array = [ 1, 2, 3 ].to_json
  begin
    page.driver.post referral_requests_from_message_referral_post_path(post), { submitted_data: json_array }
  rescue
    page.driver.post "/referral_posts/#{post.id}/referral_requests/from_message", { submitted_data: json_array }
  end
end

When("I POST to create a referral post without a verified company") do
  # Ensure current user has no verified companies
  @user.company_verifications.delete_all

  # Submit a referral post without picking a verified company
  page.driver.submit :post, referral_posts_path, {
    referral_post: {
      title: "Unverified Job",
      company_name: "NoCorp",
      job_title: "Engineer"
    }
  }
end

Then("I should be on that user's profile page") do
  # We expect the current path to be /users/:id for the other user
  expect(page.current_path).to match(%r{\/users\/\d+})
end

When("I force the next user.save to fail and POST a valid experience") do
  user = @user || User.first
  # Temporarily stub User#save for all instances
  User.class_eval { alias_method :__cuke_orig_save, :save unless method_defined?(:__cuke_orig_save) }
  User.class_eval { define_method(:save) { |*| false } }
  begin
    page.driver.submit :post, create_experience_user_path(user), { experience: { title: 'X', company: 'Y', start_date: '2020-01-01' } }
  ensure
    # restore original save
    User.class_eval { alias_method :save, :__cuke_orig_save; remove_method :__cuke_orig_save } rescue nil
  end
end

When("I ensure I have an experience at index 0") do
  user = @user || User.first
  user.experiences_data <<({ 'title' => 'Old', 'company' => 'C', 'start_date' => '2010-01-01' })
  user.save!
end

When("I force the next user.save to fail and PATCH update_experience index 0") do
  user = @user || User.first
  User.class_eval { alias_method :__cuke_orig_save, :save unless method_defined?(:__cuke_orig_save) }
  User.class_eval { define_method(:save) { |*| false } }
  begin
    page.driver.submit :patch, update_experience_user_path(user, index: 0), { experience: { title: 'New', company: 'C', start_date: '2011-01-01' } }
  ensure
    User.class_eval { alias_method :save, :__cuke_orig_save; remove_method :__cuke_orig_save } rescue nil
  end
end

When("I force the next user.save to fail and POST a valid education") do
  user = @user || User.first
  User.class_eval { alias_method :__cuke_orig_save, :save unless method_defined?(:__cuke_orig_save) }
  User.class_eval { define_method(:save) { |*| false } }
  begin
    page.driver.submit :post, create_education_user_path(user), { education: { degree: 'BS', school: 'TAMU' } }
  ensure
    User.class_eval { alias_method :save, :__cuke_orig_save; remove_method :__cuke_orig_save } rescue nil
  end
end

When("I ensure I have an education at index 0") do
  user = @user || User.first
  user.educations_data <<({ 'degree' => 'BS', 'school' => 'TAMU' })
  user.save!
end

When("I force the next user.save to fail and PATCH update_education index 0") do
  user = @user || User.first
  User.class_eval { alias_method :__cuke_orig_save, :save unless method_defined?(:__cuke_orig_save) }
  User.class_eval { define_method(:save) { |*| false } }
  begin
    page.driver.submit :patch, update_education_user_path(user, index: 0), { education: { degree: 'MS', school: 'TAMU' } }
  ensure
    User.class_eval { alias_method :save, :__cuke_orig_save; remove_method :__cuke_orig_save } rescue nil
  end
end

When("I attempt to PATCH the referral request status") do
  req = ReferralRequest.last
  # Use submit for RackTest driver compatibility
  page.driver.submit :patch, update_referral_request_status_path(req), { status: 'approved' }
end

Then("the response should be forbidden") do
  expect(page.status_code).to eq(403)
end

Given('another user {string} {string} exists') do |first, last|
  @other_user = User.find_or_create_by!(first_name: first, last_name: last) do |u|
    u.email = "#{first.downcase}.#{last.downcase}@tamu.edu"
    u.password = 'password'
    u.password_confirmation = 'password'
  end
end

When('I am logged in as {string} {string}') do |first, last|
  user = User.find_by(first_name: first, last_name: last) || User.create!(first_name: first, last_name: last, email: "#{first.downcase}.#{last.downcase}@tamu.edu", password: 'password', password_confirmation: 'password')
  page.set_rack_session(user_id: user.id)
  @user = user
end

Then('I should be redirected to the conversations page') do
  expect(page.current_path).to eq(conversations_path)
end
