Feature: Experience Management
  As a registered user
  I want to be able to add and edit my work experience
  So that I can showcase my career history

  Background:
    Given I am logged in

  Scenario: User adds experience successfully
    Given I am on my profile page
    When I click "Add Experience"
    And I fill in "Title" with "Senior Developer"
    And I fill in "Company" with "Tech Corp"
    And I fill in "Start Date" with "2020-01-01"
    And I fill in "End Date" with "2021-01-01"
    And I click "Add Experience"
    Then I should be redirected to my profile page
    And I should see "Experience added!"
    And I should see "Senior Developer"
    And I should see "Tech Corp"

  Scenario: User fails to add experience
    Given I am on my profile page
    When I click "Add Experience"
    And I click "Add Experience"
    Then I should see "Failed to add experience"

  Scenario: User edits experience successfully
    Given I have an existing experience
    And I am on my profile page
    When I click "Edit" within the experience section
    And I fill in "Title" with "Lead Developer"
    And I click "Update Experience"
    Then I should be redirected to my profile page
    And I should see "Experience updated successfully!"
    And I should see "Lead Developer"

  Scenario: Logged in user verifies company email and is redirected to profile
    And I have a pending verification for "Microsoft" with token "ms_token"
    When I visit the company verification link with token "ms_token"
    Then I should see "Company email has been successfully verified!"
    And I should be redirected to my profile page

  Scenario: Guest user verifies company email and is redirected to root
    Given a user exists with email "guest@tamu.edu" and token "user_token"
    And that user has a pending verification for "Amazon" with token "amz_token"
    When I visit the company verification link with token "amz_token"
    Then I should see "Company email has been successfully verified!"
    