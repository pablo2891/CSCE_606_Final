Feature: Coverage - targeted remaining branches
  Background:
    Given I am logged in

  Scenario: Helper normalization is callable via test harness
    When I visit "/test/coverage_helper"
    Then I should see "true"

  Scenario: Messages are marked as read when viewing conversation
    Given another user exists "Sam" "Roe"
    And there is a conversation between current user and "Sam" "Roe"
    And the conversation has unread messages from "Sam Roe"
    When I visit the conversation with "Sam Roe"
    Then the message should be marked as read

  Scenario: Creating a referral post without a verified company shows an error
    When I POST to create a referral post without a verified company
    Then I should see "You must pick one of your verified companies."
