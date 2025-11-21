Feature: Referral Management
  As a registered user
  I want to be able to create referral posts and request referrals
  So that I can help others or get help finding a job

  Background:
    Given I am logged in
    And I have a verified company "Tech Corp"

Scenario: User creates a referral post successfully
  Given I am on the new referral post page
  When I fill in "Public Title" with "Senior Dev Role"
  And I select "Tech Corp" from "Company"
  And I fill in "Job Title" with "Senior Developer"
  And I click "Create Referral Post"
  Then I should be redirected to the created referral post
  And I should see "Senior Dev Role"
  And I should see "Tech Corp"

Scenario: User requests a referral successfully
  Given there is a referral post for "Tech Corp"
  And I am on the referral posts page
  When I click "Request Referral"
  Then I should see "Request sent!"
  And I should see the referral request status as "Pending"

  Scenario: User fails to create referral post with missing title
    Given I am on the new referral post page
    When I fill in "Public Title" with ""
    And I select "Tech Corp" from "Company"
    And I click "Create Referral Post"
    Then I should see "Title can't be blank"

  Scenario: User fails to request referral (already requested)
    Given there is a referral post for "Tech Corp"
    And I have already requested a referral for this post
    And I am on the referral posts page
    Then I should see "Pending"
    And I should not see "Request Referral"

  Scenario: User sees failure message when attempting duplicate referral request
    Given there is a referral post for "Tech Corp"
    And I have already requested a referral for this post
    When I force a duplicate referral request
    Then I should see "Failed to send request."
