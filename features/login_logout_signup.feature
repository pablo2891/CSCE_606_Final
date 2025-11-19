Feature: User Authentication
  As a visitor or registered user
  I want to be able to sign up, log in, and log out
  So that I can use the application securely

  Scenario: User signs up
    Given I am on the signup page
    When I fill in valid signup information
    And I submit the form
    Then I should see a welcome message

  Scenario: User logs in
    Given I have an account
    And I am on the login page
    When I fill in valid login credentials
    And I submit the form
    Then I should see my profile page

  Scenario: User logs out
    Given I am logged in
    When I click logout
    Then I should see the homepage

  Scenario: User leaves field empty in sign up
    Given I am on the signup page
    And I forget to fill in signup information
    And I submit the form
    Then I should see the signup page
    And I should see a can't be blank signup warning

  Scenario: Malicious user tries to access non-existent route
    Given I am not logged in
    When I visit a non-existent page
    Then I should be redirected to the login page
    And I should see "You must be logged in to access this section"
  
  Scenario: User attempts incorrect login
    Given I am on the login page
    When I fill in invalid login credentials
    And I submit the form
    Then I should see "Invalid email or password"

  Scenario: Logged in user attempts to access login path
    Given I am logged in
    When I visit "/session/new"
    Then I should be redirected to my profile page
    And I should see "You are already logged in!"

  Scenario: Logged in user tries to access non-existent route
    Given I am logged in
    When I visit a non-existent page
    Then I should be redirected to my profile page
    And I should see "Redirected to your profile"