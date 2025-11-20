Feature: Education Management
  As a registered user
  I want to be able to add and edit my education
  So that I can showcase my academic background

  Background:
    Given I am logged in

  Scenario: User adds education successfully
    Given I am on my profile page
    When I click "Add Education"
    And I fill in "Degree" with "BS Computer Science"
    And I fill in "School" with "Texas A&M"
    And I fill in "Start Date" with "2016-09-01"
    And I fill in "End Date" with "2020-05-01"
    And I click "Add Education"
    Then I should be redirected to my profile page
    And I should see "Education added!"
    And I should see "BS Computer Science"
    And I should see "Texas A&M"

  Scenario: User fails to add education
    Given I am on my profile page
    When I click "Add Education"
    And I click "Add Education"
    Then I should see "Failed to add education"

  Scenario: User edits education successfully
    Given I have an existing education
    And I am on my profile page
    When I click "Edit" within the education section
    And I fill in "Degree" with "MS Computer Science"
    And I click "Update Education"
    Then I should be redirected to my profile page
    And I should see "Education updated successfully!"
    And I should see "MS Computer Science"
