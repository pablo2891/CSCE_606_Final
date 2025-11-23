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

  Scenario: User accesses new company verification page with company name parameter
    Given I have an existing experience at "Tesla"
    When I visit the new company verification page with company "Tesla"
    Then I should see the company verification form

  Scenario: User accesses new company verification page without company name
    When I visit the new company verification page
    Then I should see the company verification form
    And the company name field should be empty

  Scenario: User successfully verifies company via verify endpoint
    Given I have a pending verification for "Netflix" with id 123
    When I visit the verify endpoint for verification 123 with valid token
    Then I should see "Company email successfully verified!"
    And I should be redirected to company verifications page

  Scenario: User fails to verify via verify endpoint with invalid token
    Given I am not logged in
    Given I have a pending verification for "Netflix" with id 123
    When I visit the verify endpoint for verification 123 with invalid token
    Then I should see "You must be logged in to access this section"
    Then I should be redirected to new session path

  Scenario: User views index page with both verified and pending verifications
    Given I have a verified company "Google"
    And I have a pending verification for "Microsoft"
    When I visit the company verifications page
    Then I should see "Google" in the verified list
    And I should see "Microsoft" in the pending list