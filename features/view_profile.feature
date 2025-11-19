Feature: View User Profile
  As a registered user
  I want to view a complete profile page showing my summary, resume link, GitHub/LinkedIn URLs, contact email, and professional experiences
  So that I can present my background clearly to others.

  Scenario: Logged-in user views their own profile
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit my profile page
    Then I should see "John Doe"
    And I should see my email address
    And I should see my experiences
    And I should see my education entries

  Scenario: Logged-in user views another existing user's profile
    Given I am logged in
    And another user exists with first name "Alice" and last name "Smith"
    When I visit the profile page for "Alice Smith"
    Then I should see "Alice Smith"
    And I should not see an Edit Profile button

  Scenario: Logged-in user attempts to view a profile that does not exist
    Given I am logged in
    When I visit the profile page for a user with ID "99999"
    Then I should see an error message "User not found"
    And I should be redirected to the homepage

  Scenario: Not logged-in user attempts to view a user profile
    Given I am not logged in
    When I visit the profile page of any user
    Then I should be redirected to the login page
    And I should see a message "You must be logged in to access that page."

