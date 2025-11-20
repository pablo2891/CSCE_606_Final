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
