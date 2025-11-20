Feature: Email Verification
  As a user
  I want to verify my email addresses
  So that I can access full features of the site

  Scenario: User verifies TAMU email successfully
    Given a user exists with email "test@tamu.edu" and token "valid_token"
    When I visit the TAMU verification link with token "valid_token"
    Then I should see "Your TAMU email has been successfully verified!"
    And the user "test@tamu.edu" should be TAMU verified

  Scenario: User fails to verify TAMU email with invalid token
    Given a user exists with email "test@tamu.edu" and token "valid_token"
    When I visit the TAMU verification link with token "invalid_token"
    Then I should see "Invalid or expired verification link."
    And the user "test@tamu.edu" should not be TAMU verified

  Scenario: User verifies company email successfully
    Given a company verification exists for "Google" with token "valid_token"
    When I visit the company verification link with token "valid_token"
    Then I should see "Company email has been successfully verified!"
    And the company verification for "Google" should be verified

  Scenario: User fails to verify company email with invalid token
    Given a company verification exists for "Google" with token "valid_token"
    When I visit the company verification link with token "invalid_token"
    Then I should see "Invalid or expired verification link."
    And the company verification for "Google" should not be verified
