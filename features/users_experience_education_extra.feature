Feature: User experience and education edge cases
  As a user
  I want validation errors to render the add forms

  Background:
    Given I am logged in

  Scenario: Fail to add experience with missing required fields
    When I visit my add experience page
    And I fill in "Title" with ""
    And I fill in "Company" with ""
    And I click "Add Experience"
    Then I should see "Failed to add experience."

  Scenario: Fail to add education with missing required fields
    When I visit the add education page for "Test" "User"
    And I fill in "Degree" with ""
    And I fill in "School" with ""
    And I click "Add Education"
    Then I should see "Failed to add education."
