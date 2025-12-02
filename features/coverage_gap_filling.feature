Feature: Coverage Gap Filling
  As a developer
  I want to ensure all code paths are covered
  So that I can achieve 100% test coverage

  Background:
    Given I am logged in as a user with email "test@tamu.edu"

  # UsersController#update - Remove Resume
  Scenario: User removes resume
    Given I have a resume attached
    When I visit my edit profile page
    And I check "Remove resume"
    And I click "Save Changes"
    Then I should see "Profile updated successfully!"

  # UsersController#update - Password Change Failures
  Scenario: User fails to update password with missing old password
    When I visit my edit profile page
    And I fill in "New password" with "newpassword123"
    And I click "Save Changes"
    Then I should see "Old password is incorrect"

  Scenario: User fails to update password with incorrect old password
    When I visit my edit profile page
    And I fill in "Current password" with "wrongpassword"
    And I fill in "New password" with "newpassword123"
    And I click "Save Changes"
    Then I should see "Old password is incorrect"

  # UsersController#create_experience - Validation Failures
  Scenario: User fails to add experience with invalid dates
    When I visit my add experience page
    And I fill in "Title" with "Developer"
    And I fill in "Company" with "Tech Corp"
    And I fill in "Start Date" with "2024-01-01"
    And I fill in "End Date" with "2023-01-01"
    And I click "Add Experience"
    Then I should see "Failed to add experience"

  # UsersController#create_education - Validation Failures
  Scenario: User fails to add education with invalid dates
    When I visit the add education page
    And I fill in "Degree" with "BS"
    And I fill in "School" with "TAMU"
    And I fill in "Start Date" with "2024-01-01"
    And I fill in "End Date" with "2023-01-01"
    And I click "Add Education"
    Then I should see "Failed to add education"

  # CompanyVerificationsController#create - Save Failure
  Scenario: Company verification creation fails (database error)
    Given I force company verification save to fail
    When I visit the new company verification page
    And I fill in "Company Name" with "Google"
    And I fill in "Company Email" with "recruiter@google.com"
    And I click "Send Verification Email"
    Then I should see "Failed to create company verification"

  # CompanyVerificationsController#verify - Invalid Token
  Scenario: Company verification fails with invalid token
    Given a company verification exists for "Google" with token "valid_token"
    When I visit the verification link with token "invalid_token"
    Then I should see "Invalid or expired verification link"

  # UsersController#delete_experience - Save Failure
  Scenario: Delete experience fails
    Given I have an experience entry
    And I force user save to fail
    When I delete the experience entry
    Then I should see "Failed to delete experience entry"

  # UsersController#delete_education - Save Failure
  Scenario: Delete education fails
    Given I have an education entry
    And I force user save to fail
    When I delete the education entry
    Then I should see "Failed to delete education entry"

  # ReferralPostsController#destroy
  Scenario: User deletes their referral post
    Given I have a referral post titled "Software Engineer"
    When I visit my referral posts page
    And I click "Delete" for the post "Software Engineer"
    Then I should see "Referral post deleted."

  # ReferralPostsController#authorize_owner!
  Scenario: User tries to edit someone else's referral post
    Given another user has a referral post titled "Product Manager"
    When I try to edit the post "Product Manager"
    Then I should see "Unauthorized"

  # EmailVerificationsController#verify_company - Guest Access
  Scenario: Guest visits company verification link
    Given I am not logged in
    And a company verification exists for "Apple" with token "guest_token"
    When I visit the company verification link with token "guest_token"
    Then I should see "Company email has been successfully verified!"
    And I should be on the login page

  # ReferralPost scope :search
  Scenario: User searches for a referral post
    Given another user has a referral post titled "Software Engineer"
    When I visit the referral posts page
    And I search for "Software"
    Then I should see "Software Engineer"

  # ConversationsController#destroy - Unauthorized
  Scenario: User tries to delete someone else's conversation
    Given another user has a conversation
    When I try to delete the conversation
    Then I should see "Unauthorized"

  # ReferralRequestsController#update_status - Invalid Status
  Scenario: User updates referral request with invalid status
    Given I have a referral post titled "Software Engineer"
    And I have a referral request for "Software Engineer"
    When I update the request status to "invalid_status"
    Then I should see "Invalid status"

  # ReferralRequestsController#update_status - Reopen Post
  Scenario: User reverts approved request and reopens post
    Given I have a referral post titled "Software Engineer"
    And I have a referral request for "Software Engineer"
    And I update the request status to "approved"
    When I update the request status to "pending"
    Then the post "Software Engineer" should be active

  # ReferralRequestsController#update_status - Error Handling
  Scenario: Error during request status update
    Given I have a referral post titled "Software Engineer"
    And I have a referral request for "Software Engineer"
    And I force request status update to fail
    When I update the request status to "approved"
  # ReferralRequestsController#normalize_submitted_data - Array input
  Scenario: User submits array data for referral request
    Given I have a referral post titled "Software Engineer"
    And I submit a referral request with array data
    Then I should see "Request sent!"
