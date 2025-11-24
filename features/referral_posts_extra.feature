Feature: Referral posts edge cases
  As a user
  I want errors for trying to create posts without a verified company

  Background:
    Given I am logged in

  Scenario: Fail to create referral post without verified company
    When I visit the new referral post page
    And I fill in "Public Title" with "SWE Role"
    And I fill in "Job Title" with "Software Engineer"
    And I click "Create Referral Post"
    Then I should see "You must pick one of your verified companies."

  Scenario: Visiting a non-existent referral post shows dashboard redirect
    When I visit "/referral_posts/999999"
    Then I should be redirected to the dashboard page
