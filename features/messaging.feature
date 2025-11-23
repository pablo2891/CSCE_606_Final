Feature: Messaging System
  As a user
  I want to communicate with other users
  So that I can discuss referral opportunities

  Background:
    Given I am logged in
    And another user "Jane Doe" exists

  Scenario: View conversations list
    Given I have a conversation with "Jane Doe"
    When I visit the conversations page
    Then I should see my conversations list
    And I should see "Jane Doe" in my conversations

  Scenario: View conversation messages
    Given I have a conversation with "Jane Doe"
    And the conversation has messages
    When I visit the conversation with "Jane Doe"
    Then I should see the message "Hello from the other user!"
    And I should see the message "My reply"

  Scenario: Send a message
    Given I have a conversation with "Jane Doe"
    When I visit the conversation with "Jane Doe"
    And I send a message "Thanks for connecting!"
    Then I should be on the conversation page
    And I should see "Message sent."
    And I should see the message "Thanks for connecting!"

  Scenario: Messages are marked as read
    Given I have a conversation with "Jane Doe"
    And the conversation has messages
    When I visit the conversation with "Jane Doe"
    Then the message should be marked as read

  Scenario: Start a new conversation
    When I start a conversation with "Jane Doe"
    Then I should see "Jane Doe" in my conversations

  Scenario: Cannot send empty message
    Given I have a conversation with "Jane Doe"
    When I visit the conversation with "Jane Doe"
    And I send a message ""
    Then I should be on the conversation page

  Scenario: View conversation with another user
    Given I have a conversation with "Jane Doe"
    And the conversation has messages
    When I visit the conversations page
    Then I should see "Jane Doe" in my conversations
    And I should see "Test Conversation"