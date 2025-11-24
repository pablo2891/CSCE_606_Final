Feature: Resume upload
  As a logged in user
  I want to upload my resume so that it is stored with Active Storage

  Background:
    Given I am logged in
    When I visit my edit profile page

  Scenario: Upload a valid PDF resume
    When I attach "spec/fixtures/files/sample.pdf" to "user_resume"
    And I press "Save Changes"
    Then I should be redirected to the profile page for "Test" "User"
    And I should see my resume file attached

  Scenario: Upload a non-PDF file is rejected
    When I attach a non-pdf file to "user_resume"
    And I press "Save Changes"
    Then I should see "must be a PDF"

  Scenario: Upload an oversized file is rejected
    When I attach an oversized file to "user_resume"
    And I press "Save Changes"
    Then I should see "size must be less than 5 MB"
