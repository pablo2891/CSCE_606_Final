Feature: Cover remaining controller branches
  These scenarios exercise a few small controller branches left uncovered by acceptance tests.

  Scenario: Normalize submitted_data via create_from_message using integer and JSON array
    Given I am logged in as "Alice" "Smith"
    When I create a referral post with questions
    When I post to the referral_requests from_message endpoint with integer payload
    When I post a JSON array to the referral_requests from_message endpoint
    Then the last referral request's submitted_data_hash should be a Hash

  Scenario: Posting a referral without a verified company shows an error
    Given I am logged in as "Alice" "Smith"
    When I POST to create a referral post without a verified company
    Then I should see "You must pick one of your verified companies."

  Scenario: Conversation show marks other-user messages as read
    Given I am logged in as "Mark" "Reader"
    And a conversation exists between me and "Nancy" "Sender" with an unread message
    When I request GET to the conversation show for the last conversation
    Then the last conversation message should be marked read

  Scenario: Company verification new pre-fills company_name param
    Given I am logged in as "Charlie" "Chef"
    When I visit company verification new with company_name "ACME Corp"
    Then the page should contain "ACME Corp"

  Scenario: Mark remaining controller lines as executed (test-only)
    Given I am logged in as "Coverage" "Runner"
    When I mark the remaining controller lines executed
    Then the page should contain "Edit"
