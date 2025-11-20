Feature: Edit User Profile
  As a logged-in user
  I want to edit my profile information (summary, headline, resume URL, GitHub, LinkedIn)
  So that I can keep my profile up to date.

  Scenario: Logged-in user successfully edits all profile fields
    Given I am logged in as a user with first name "John" and last name "Doe"
    When I visit my edit profile page
    And I fill in the profile form with:
      | Headline     | Senior Developer |
      | Summary      | I build cool things. |
      | Resume URL   | http://example.com/resume.pdf |
      | GitHub URL   | https://github.com/johndoe |
      | LinkedIn URL | https://linkedin.com/in/johndoe |
    And I press "Save"
    Then I should see "Profile updated successfully!"
    And I should be redirected to my profile page
    And I should see "Senior Developer"
    And I should see "I build cool things."

  Scenario: User updates only their resume URL
    Given I am logged in
    And I visit my edit profile page
    When I fill in "Resume URL" with "http://example.com/new_resume.pdf"
    And I press "Save"
    Then I should see "Profile updated successfully!"
    And I should find my resume link "http://example.com/new_resume.pdf" on my profile page

  Scenario: User submits new password without confirmation
    Given I am logged in
    And I visit my edit profile page
    When I fill in "Password" with "newpassword123"
    And I press "Save"
    Then I should see "Password confirmation doesn't match Password"

  Scenario: Logged-in user attempts to edit another user's profile
    Given I am logged in as a user with first name "John" and last name "Doe"
    And another user exists with first name "Alice" and last name "Smith"
    When I visit the edit profile page for "Alice" "Smith"
    Then I should see "Unauthorized"
    And I should be on the profile page for "Alice" "Smith"
