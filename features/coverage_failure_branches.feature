Feature: Coverage - failure branches via forced save failures
  Background:
    Given I am logged in

  Scenario: create_experience path when @user.save fails
    When I force the next user.save to fail and POST a valid experience
    Then I should see "Add Experience"

  Scenario: update_experience path when @user.save fails
    When I ensure I have an experience at index 0
    And I force the next user.save to fail and PATCH update_experience index 0
    Then I should see "Edit Experience"

  Scenario: create_education path when @user.save fails
    When I force the next user.save to fail and POST a valid education
    Then I should see "Add Education"

  Scenario: update_education path when @user.save fails
    When I ensure I have an education at index 0
    And I force the next user.save to fail and PATCH update_education index 0
    Then I should see "Edit Education"

  Scenario: referral_requests update_status forbidden for non-owner
    Given there is a referral post for "Tech Corp"
    And another user "Jane" "Doe" exists
    And "Jane Doe" has requested the referral
    When I am logged in as "John" "Smith"
    And I attempt to PATCH the referral request status
    Then the response should be forbidden

  Scenario: unauthorized conversation show redirects
    Given another user exists "Alice" "Smith"
    And another user exists "Bob" "Jones"
    And there is a conversation between "Alice" "Smith" and "Bob" "Jones"
    When I visit the conversation page for the last conversation
    Then I should be redirected to the conversations page
