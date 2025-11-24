Feature: Email verification redirects
  As a user
  I want the company verification email link to redirect me to my profile when logged in

  Background:
    Given I am logged in

  Scenario: Clicking company verification link while logged in redirects to profile
    Given I have a pending verification for "Test Co"
    When I visit the company verification link for the last verification
    Then I should be redirected to my profile page
