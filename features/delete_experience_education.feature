Feature: Delete Experience/Education
  As a registered user
  I want to delete my work experience or education
  So that I can remove outdated or incorrect entries

  Scenario: User deletes an experience successfully from edit profile
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit my edit profile page
    And I click "Delete" next to the "Software Intern" experience
    Then I should be redirected to my profile page
    And I should see "Experience entry deleted."
    And I should not see "Software Intern"

  Scenario: User deletes an experience successfully from edit experience
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the edit experience page for index 0
    And I click "Delete Experience"
    Then I should be redirected to my profile page
    And I should see "Experience entry deleted."
    And I should not see "Software Intern"

Scenario: User fails to delete experience due to save failure
    Given I am logged in as a user with first name "John" and last name "Doe"
    And saving the user should fail
    When I visit my edit profile page
    And I click "Delete" next to the "Software Intern" experience
    Then I should see "Failed to delete experience entry."
    And I should see "Software Intern"

  Scenario: User deletes an education successfully from edit profile
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit my edit profile page
    And I click "Delete" next to the "BS Computer Engineering" education
    Then I should be redirected to my profile page
    And I should see "Education entry deleted."
    And I should not see "BS Computer Engineering"

  Scenario: User deletes an education successfully from edit education
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit the edit education page for index 0
    And I click "Delete Education"
    Then I should be redirected to my profile page
    And I should see "Education entry deleted."
    And I should not see "BS Computer Engineering"
  
  Scenario: User fails to delete education due to save failure
    Given I am logged in as a user with first name "John" and last name "Doe"
    And saving the user should fail
    When I visit my edit profile page
    And I click "Delete" next to the "BS Computer Engineering" education
    Then I should see "Failed to delete education entry."
    And I should see "BS Computer Engineering"

  
