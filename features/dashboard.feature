Feature: Dashboard Management
  As a user
  I want to view and filter referral posts on dashboard
  So that I can find referral posts that matches with my criterias

  Background:
    Given I am logged in
    Given the following referral posts exist:
    | company   | department         | status | location | level        | type       | posted | jobtitle               |
    | Tech Corp | Product Management | Active | Hybrid   | Senior Level | Full-time  | 0      | Senior Product Manager |
    | TI        | Product Management | Active | Hybrid   | Senior Level | Full-time  | 6      | Senior Product Manager |
    | Microsoft | Product Management | Active | Hybrid   | Senior Level | Full-time  | 2      | Senior Product Manager |
    | Google    | Sales              | Paused | On-site  | Internship   | Internship | 0      | Sales Intern           |
    | Amazon    | Sales              | Active | On-site  | Mid Level    | Contract   | 89     | Account Executive      |
    | Paycom    | Sales              | Active | On-site  | Mid Level    | Contract   | 29     | Sales Representative   |
    | Netflix   | Engineering        | Active | Remote   | Senior Level | Full-time  | 179    | Senior Backend Engineer|
    | LinkedIn  | Engineering        | Active | Remote   | Senior Level | Full-time  | 355    | Staff Software Engineer|
    | Meta      | Marketing          | Closed | On-site  | Internship   | Internship | 0      | Marketing Intern       |
    | Tesla     | Manufacturing      | Active | On-site  | Entry Level  | Full-time  | 5      | Production Associate   |
    | AppleBee  | Design             | Active | Hybrid   | Mid Level    | Temporary  | 500    | UX Designer            |
    | Spotify   | Data Science       | Active | Remote   | Entry Level  | Part-time  | 3      | Junior Data Analyst    |
    | Oracle    | Human Resources    | Active | On-site  | Senior Level | Full-time  | 15     | HR Business Partner    |
    | Airbnb    | Operations         | Active | Hybrid   | Internship   | Internship | 20     | Operations Intern      |
    | IBM       | Consulting         | Active | Remote   | Mid Level    | Contract   | 60     | Strategy Consultant    |

  Scenario: View Active Posts by Default
    When I visit the dashboard page
    Then I should see "Job at Tech Corp"
    Then I should not see "Job at Meta"
    Then I should not see "Job at Google"

  Scenario: View Paused Posts
    When I visit the dashboard page
    And I select "Paused" from "Post Status"
    And I click navigation "Apply Filters"
    Then I should not see "Job at Tech Corp"
    Then I should see "Job at Google"
    Then I should not see "Job at Meta"

  Scenario: View Closed Posts
    When I visit the dashboard page
    And I select "Closed" from "Post Status"
    And I click navigation "Apply Filters"
    Then I should not see "Job at Tech Corp"
    Then I should not see "Job at Google"
    Then I should see "Job at Meta"

  Scenario: View Posts created in the past 1 days
    When I visit the dashboard page
    And I select "24 hours" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at Tech Corp"
    Then I should not see "Job at TI"
    Then I should not see "Job at Paycom"

  Scenario: View Posts created in the past 7 days
    When I visit the dashboard page
    And I select "7 days" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at Tech Corp"
    Then I should see "Job at TI"
    Then I should not see "Job at Paycom"
    Then I should not see "Job at Amazon"
    Then I should not see "Job at Netflix"
    Then I should not see "Job at LinkedIn"

  Scenario: View Posts created in the past 30 days
    When I visit the dashboard page
    And I select "30 days" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at Tech Corp"
    Then I should see "Job at TI"
    Then I should see "Job at Paycom"
    Then I should not see "Job at Amazon"
    Then I should not see "Job at Netflix"
    Then I should not see "Job at LinkedIn"

  Scenario: View Posts created in the past 90 days
    When I visit the dashboard page
    And I select "90 days" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at Amazon"
    Then I should not see "Job at Netflix"
    Then I should not see "Job at LinkedIn"

  Scenario: View Posts created in the past 180 days
    When I visit the dashboard page
    And I select "180 days" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at Netflix"
    Then I should not see "Job at LinkedIn"

  Scenario: View Posts created in the past year
    When I visit the dashboard page
    And I select "1 year" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at LinkedIn"

  Scenario: View Posts created any time
    When I visit the dashboard page
    And I select "Any" from "Posted"
    And I click navigation "Apply Filters"
    Then I should see "Job at AppleBee"

  Scenario: View Posts created by company
    When I visit the dashboard page
    And I fill in form "Company" with "Paycom"
    And I click navigation "Apply Filters"
    Then I should see "Job at Paycom"

  Scenario: View Posts by department
    When I visit the dashboard page
    And I fill in form "Department" with "Engineering"
    And I click navigation "Apply Filters"
    Then I should see "Job at Netflix"
    Then I should see "Job at LinkedIn"
    
  Scenario: View Posts by location
    When I visit the dashboard page
    And I select "Remote" from "Location"
    And I click navigation "Apply Filters"
    Then I should see "Job at Netflix"
    And I should see "Job at Spotify"
    And I should see "Job at IBM"

  Scenario: View Posts by job level
    When I visit the dashboard page
    And I select "Senior Level" from "Level"
    And I click navigation "Apply Filters"
    Then I should see "Job at Microsoft"
    And I should see "Job at Oracle"
    And I should see "Job at LinkedIn"

  Scenario: View Posts by employment type
    When I visit the dashboard page
    And I select "Contract" from "Type"
    And I click navigation "Apply Filters"
    Then I should see "Job at Amazon"
    And I should see "Job at Paycom"

  Scenario: View posts by job title
    When I visit the dashboard page
    And I fill in form "Job Title" with "UX Designer"
    And I click navigation "Apply Filters"
    Then I should see "Job at AppleBee"

  Scenario: View posts not by the current user
    When I visit the dashboard page
    And I fill in form "Referrer Username" with "Nobody"
    And I click navigation "Apply Filters"
    Then I should see "No referrals found matching your criteria."