Feature: Edit/Add Experience & Education
  As a logged-in user
  I want to create, edit, and delete experience and education items
  So that my profile accurately reflects my work and academic background.

  Scenario: Add experience page for self
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit my add experience page
    Then I should see the experience form

  Scenario: Add experience page for another user
    Given I am logged in as a user with first name "John" and last name "Doe"
    And another user exists with first name "Alice" and last name "Smith"
    When I visit the add experience page of a user with first name "Alice" and last name "Smith"
    Then I should see an alert "Unauthorized"
    And I should be redirected to the profile page for "Alice" "Smith"

  Scenario: Create valid experience
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I submit a new experience with title "Developer" and company "TAMU"
    Then I should be redirected to my profile
    And I should see "Experience added!"

  Scenario: Edit existing experience
    Given I am logged in as a user with first name "John" and last name "Doe"
    And I have an experience titled "Developer"
    When I visit the edit experience page for index 1
    Then I should see the experience form with title "Developer"

  Scenario: Update experience successfully
    Given I am logged in as a user with first name "John" and last name "Doe"
    And I have an experience titled "Developer"
    When I update experience index 0 with title "Senior Developer"
    Then I should be redirected to my profile
    And I should see "Experience updated successfully!"

  Scenario: Unauthorized experience update
    Given I am logged in as a user with first name "John" and last name "Doe"
    And another user exists with first name "Alice" and last name "Smith"
    When I attempt to update Alice Smith's experience
    Then I should see an alert "Unauthorized"
    And I should be redirected to the profile page for "Alice" "Smith"

  Scenario: Logged-in user views the add education form
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the add education page for "John" "Doe"
    Then I should see the education form

  Scenario: User successfully adds an education entry
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the add education page for "John" "Doe"
    And I fill in the education form with:
      | degree      | MS Electrical Engineering |
      | school      | Stanford University       |
      | start_date  | 2023-08-01                |
      | end_date    | 2025-05-01                |
      | description | Graduate studies          |
    And I submit the education form
    Then I should see "Education added!"
    And I should be redirected to the profile page for "John" "Doe"

  Scenario: User visits the edit education page
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the edit education page for entry 0 of "John" "Doe"
    Then I should see "BS Computer Engineering" under the "Degree" field
    And I should see the education form
  
  Scenario: User successfully updates an education entry
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the edit education page for entry 0 of "John" "Doe"
    And I fill in the education form with:
      | degree | MS Computer Engineering |
    And I submit the education form
    Then I should see "Education updated successfully!"
    And I should be redirected to the profile page for "John" "Doe"
    And I should see "MS Computer Engineering"
  
  Scenario: Unauthorized user cannot access another user's add education page
    Given I am logged in as a user with first name "John" and last name "Doe"
    And another user exists with first name "Alice" and last name "Smith"
    When I visit the add education page for "Alice" "Smith"
    Then I should see "Unauthorized"
    And I should be redirected to the profile page for "Alice" "Smith"

  Scenario: Unauthorized user cannot update another user's education
    Given I am logged in as a user with first name "John" and last name "Doe"
    And another user exists with first name "Alice" and last name "Smith"
    When I visit the update education page of entry 0 for "Alice" "Smith"
    Then I should see "Redirected to your profile."
    And I should be redirected to the profile page for "John" "Doe"
