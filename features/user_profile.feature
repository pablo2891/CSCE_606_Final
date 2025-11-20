Feature: User Profile Management
  As a registered user
  I want to be able to edit my profile
  So that I can keep my information up to date

  Background:
    Given I am logged in

  Scenario: User edits profile successfully
    Given I am on my profile page
    When I click "Edit Profile"
    And I fill in "First name" with "Updated"
    And I fill in "Headline" with "Software Engineer"
    And I click "Save Changes"
    Then I should be redirected to my profile page
    And I should see "Profile updated successfully!"
    And I should see "Updated"
    And I should see "Software Engineer"

  Scenario: User updates profile with invalid data
    Given I am on my profile page
    When I click "Edit Profile"
    And I fill in "Email" with ""
    And I click "Save Changes"
    Then I should see "Edit Profile"
    And I should see "Email can't be blank"
