Feature: Referral Request Management
  As a user
  I want to manage referral requests
  So that I can help candidates or get help

  Background:
    Given I am logged in
    And I have a verified company "Tech Corp"

  Scenario: Post owner approves a request
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    When I visit the dashboard page
    And I approve the request from "Jane Doe"
    Then I should see "Request status updated"
    And the post should be closed

  Scenario: Post owner rejects a request
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    When I visit the dashboard page
    And I reject the request from "Jane Doe"
    Then I should see "Request status updated"

  Scenario: Cannot apply to closed post
    Given there is a closed referral post for "Tech Corp"
    When I try to request the referral
    Then I should see "This post is closed"

  Scenario: Unauthorized user cannot update request status
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And I am logged in as "Jane Doe"
    When I try to update a request status
    Then I should see "You haven't requested any referrals yet"

 Scenario: User creates referral request with JSON string submitted_data
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with JSON submitted_data
    Then I should see "Request sent!"

  Scenario: User creates referral request with Hash submitted_data
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with Hash submitted_data
    Then I should see "Request sent!"

  Scenario: User creates referral request with ActionController::Parameters
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with params submitted_data
    Then I should see "Request sent!"

  Scenario: User creates referral request with invalid JSON string
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with invalid JSON submitted_data
    Then I should see "Request sent!"

  Scenario: User creates referral request with other type submitted_data
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request with integer submitted_data
    Then I should see "Request sent!"

  Scenario: User creates referral request from message successfully
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create a request from message endpoint
    Then the response should be successful

  Scenario: User fails to create referral request from message
    Given there is a referral post for "Tech Corp"
    And I am viewing referral posts as a different user
    When I create an invalid request from message endpoint
    Then the response should be unprocessable

  Scenario: Post owner updates request to withdrawn status
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    When I visit the dashboard page
    And I update the request to "withdrawn"
    Then I should see "Request status updated"

  Scenario: Post owner updates request to pending status
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    When I visit the dashboard page
    And I update the request to "pending"
    Then I should see "Request status updated"

  Scenario: Post owner fails to update with invalid status
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    When I visit the dashboard page
    And I try to update the request with invalid status "invalid_status"
    Then I should see "You haven't requested any referrals yet"

  Scenario: Post owner gets error on update failure
    Given there is a referral post for "Tech Corp"
    And another user "Jane Doe" exists
    And "Jane Doe" has requested the referral
    And updates will fail with validation error
    When I visit the dashboard page
    And I approve the request from "Jane Doe"
    Then I should see "You haven't requested any referrals yet"