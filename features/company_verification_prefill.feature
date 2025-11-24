Feature: Company verification prefill
  As a user
  I want the new verification form to prefill a company name from params

  Background:
    Given I am logged in

  Scenario: Visit new company verification with company_name param
    When I visit the new company verification page with company "Acme Co"
    Then the company name field should be pre-filled with "Acme Co"
