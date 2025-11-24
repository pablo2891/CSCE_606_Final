Feature: Coverage - more targeted branches
  Background:
    Given I am logged in

  Scenario: Unauthorized user cannot update another user's profile
    Given another user exists "Evil" "User"
    When I attempt to PATCH that user's profile
    Then I should be on that user's profile page

  Scenario: Profile update failure renders edit with errors
    When I submit an invalid profile update
    Then I should see "must be a valid @tamu.edu email"

  Scenario: ReferralRequest submitted_data_hash returns a Hash
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with integer submitted_data
    Then the last referral request's submitted_data_hash should be a Hash

  Scenario: create_from_message with JSON array payload
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I post a JSON array to the referral_requests from_message endpoint
    Then the response should be successful
