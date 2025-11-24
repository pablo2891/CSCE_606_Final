Feature: Conversations extra flows
  As a user
  I want to create conversations with a body and delete my conversations

  Background:
    Given I am logged in
    And another user "Jane Doe" exists

  Scenario: Create a conversation with a body and message is created
    When I start a conversation with "Jane Doe"
    Then I should see "Jane Doe"

  Scenario: Owner destroys a conversation
    Given I have a conversation with "Jane Doe"
    When I delete the conversation
    Then I should not see "Jane Doe" in my conversations
