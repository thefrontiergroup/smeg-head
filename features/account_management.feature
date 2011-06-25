Feature: Account Management
  In order to use the site
  As a user I
  Want to be able to manage my account
  
  Scenario: Signing up with Valid Details
    Given I am signed out
    And I am on the new user page
    When I fill in the following:
      | Login                 | test_user        |
      | Email                 | test@example.com |
      | Password              | password         |
      | Confirm your password | password         |
    And I click "Create my Account"
    Then I should be signed in
    And I should be redirected to the user dashboard
  
  Scenario: Signing up with Invalid Details
  
  Scenario: Editing my Profile
    Given I am a new, authenticated user
    When I go to the edit profile page
    And I fill in "Email" with "new_email@example.com"
    And I click "Update Profile"
    Then I should be on the edit profile page
    And my email should be "new_email@example.com"

  Scenario: Closing my Account
    Given I am a new, authenticated user
    When I go to the edit profile page
    And I click "Close my account"
    Then my account should no longer exist