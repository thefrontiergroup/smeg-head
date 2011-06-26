Feature: Account Management
  In order to use the site
  As a user I
  Want to be able to manage my account
  
  Scenario: Signing up with Valid Details
    Given I am signed out
    And I am on the sign up page
    When I fill in the following:
      | User name             | test_user        |
      | Email                 | test@example.com |
      | Password              | password         |
      | Confirm your password | password         |
    And I press "Sign Up"
    Then I should be signed in
    And I should be on the home page
  
  Scenario: Signing up with Invalid Details
  
  Scenario: Editing my Profile
    Given I am a new, authenticated user with the password "password"
    When I go to the edit profile page
    And I fill in "Email" with "new_email@example.com"
    And I fill in "Current password" with "password"
    And I press "Update Profile"
    Then I should be on the home page
    And my email should be "new_email@example.com"

  Scenario: Closing my Account
    Given I am a new, authenticated user
    When I go to the edit profile page
    And I press "Close my account"
    Then my account should no longer exist