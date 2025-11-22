Feature: Sending messages
  Background:
    Given I am logged in
    And another user exists "Jane" "Doe"
    And there is a conversation between current user and "Jane" "Doe"

  Scenario: Send message successfully
    When I visit the conversation page for the last conversation
    And I fill in "Body" with "Hey!"
    And I click "Send"
    Then I should see "Message sent."

  Scenario: Message validation failure
    When I visit the conversation page for the last conversation
    And I click "Send"

  Scenario: Unauthorized user cannot send message to conversation
    Given another user exists "John" "Smith"
    And there is a conversation between "John" "Smith" and "Jane" "Doe"
    When I try to send a message to their conversation
    Then I should see "Unauthorized"
    And I should be redirected to conversations page