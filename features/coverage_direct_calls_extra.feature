Feature: Coverage direct calls extra
  Background:
    Given I am logged in

  Scenario: Remove resume via direct PATCH
    When I request PATCH to my user update with param remove_resume=1
    Then I should be redirected to my profile page

  Scenario: Create experience with invalid data via direct POST
    When I request POST to create_experience with empty fields
    Then I should see "Failed to add experience."

  Scenario: Visit conversation show via direct GET
    Given another user exists "Jane" "Doe"
    And there is a conversation between current user and "Jane" "Doe"
    When I request GET to the conversation show for the last conversation
    Then I should be on the conversation page
