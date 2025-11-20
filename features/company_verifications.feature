Feature: Company Verification Management
  As a registered user
  I want to be able to verify my employment at a company
  So that I can post referrals and build trust

  Background:
    Given I am logged in

  Scenario: User adds a company verification successfully
    Given I am on the profile page
    When I click "Add Experience"
    And I fill in "Title" with "Software Engineer"
    And I fill in "Company" with "Google"
    And I fill in "Start Date" with "2022-01-01"
    And I click "Add Experience"
    Then I should see "Experience added!"
    When I click "Verify" within the "Google" experience section
    And I fill in "Company Email" with "me@google.com"
    And I click "Send Verification Email"
    Then I should see "A verification email has been sent to your company email."
    When I am on the profile page
    Then I should see "Pending" within the "Google" experience section

  Scenario: User fails to add company verification with invalid email domain
    Given I have an existing experience at "Google"
    And I am on the profile page
    When I click "Verify" within the "Google" experience section
    And I fill in "Company Email" with "me@yahoo.com"
    And I click "Send Verification Email"
    Then I should see "Your email domain must match the company name"

  Scenario: User deletes a company verification
    Given I have a pending verification for "Google"
    And I am on the company verifications page
    When I click "Delete" for "Google"
    Then I should see "Verification request deleted."
    And I should not see "Google" in the pending list
    And I should not see "Google" in the pending list

  Scenario: User fails to create company verification due to system error
    Given I have an existing experience at "Google"
    And I am on the profile page
    And the system fails to save company verifications
    When I click "Verify" within the "Google" experience section
    And I fill in "Company Email" with "me@google.com"
    And I click "Send Verification Email"
    Then I should see "Failed to create company verification"
