Feature: Referral Post management
  As a user
  I want to create, edit and delete referral posts
  So that other users can request referrals

  Background:
    Given I am logged in

  Scenario: Create referral post with questions array
    Given I have a verified company "Tech Corp"
    When I visit the new referral post page
    And I fill in "Public Title" with "SWE Role"
    And I fill in "Job Title" with "Software Engineer"
    And I select "Tech Corp" from "Company"
    And I add questions "Why do you want this role?", "What's your experience?"
    And I click "Create Referral Post"
    Then I should see "Referral post created!"
    And the post should have 2 questions

  Scenario: Create referral post with empty questions
    Given I have a verified company "Tech Corp"
    When I visit the new referral post page
    And I fill in "Public Title" with "SWE Role"
    And I fill in "Job Title" with "Software Engineer"
    And I select "Tech Corp" from "Company"
    And I add empty questions
    And I click "Create Referral Post"
    Then I should see "Referral post created!"
    And the post should have 0 questions

  Scenario: Update referral post with questions
    Given there is a referral post for "Tech Corp"
    When I visit the edit referral post page for the last post
    And I add questions "Updated question 1", "Updated question 2"
    And I click "Update Referral Post"
    Then I should see "Referral post updated!"

  Scenario: Fail to update referral post with invalid data
    Given there is a referral post for "Tech Corp"
    When I visit the edit referral post page for the last post
    And I fill in "Job Title" with ""
    And I click "Update Referral Post"
    And I should see the edit form

  Scenario: Unauthorized user cannot access edit page
    Given there is a referral post for "Tech Corp" created by another user
    When I visit the edit referral post page for the last post
    Then I should see "Unauthorized"
    And I should be redirected to referral posts index

  Scenario: Unauthorized user cannot update post
    Given there is a referral post for "Tech Corp" created by another user
    When I try to update the last referral post
    Then I should see "Welcome"

  Scenario: Unauthorized user cannot destroy post
    Given there is a referral post for "Tech Corp" created by another user
    When I try to destroy the last referral post
    Then I should see "Unauthorized"
    And I should be redirected to referral posts index