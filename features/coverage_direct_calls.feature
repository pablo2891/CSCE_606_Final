Feature: Direct controller endpoint calls to exercise branches
  As a test harness
  I want to call controller endpoints directly to execute uncovered branches

  Background:
    Given I am logged in

  Scenario: Trigger users#update remove_resume branch
    When I request PATCH to my user update with param remove_resume=1
    Then I should be redirected to my profile page

  Scenario: Trigger create_experience failure branch
    When I request POST to create_experience with empty fields
    Then I should see "Failed to add experience."

  Scenario: Trigger conversation show mark-read branch
    Given I have a conversation with "Jane Doe"
    And the conversation has unread messages from "Jane Doe"
    When I request GET to the conversation show for the last conversation
    Then I should be on the conversation page

  Scenario: Trigger referral_requests#create_from_message with integer payload
    Given there is a referral post for "Tech Corp"
    When I post to the referral_requests from_message endpoint with integer payload
    Then the response should be successful
