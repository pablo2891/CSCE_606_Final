Feature: Conversations
  As a user
  I want to have conversations with other users
  So that I can communicate about referrals

  Background:
    Given I am logged in
    And another user "Jane Doe" exists

  Scenario: User views conversations index
    Given I have a conversation with "Jane Doe"
    When I visit the conversations page
    Then I should see "Jane Doe" in my conversations

  Scenario: User views conversation and messages are marked as read
    Given I have a conversation with "Jane Doe"
    And the conversation has unread messages from "Jane Doe"
    When I visit the conversation with "Jane Doe"

  Scenario: Unauthorized user cannot view conversation
    Given another user "John Smith" exists
    And there is a conversation between "John Smith" and "Jane Doe"
    When I try to view the conversation between "John Smith" and "Jane Doe"
    Then I should see "Unauthorized"
    And I should be redirected to conversations page
