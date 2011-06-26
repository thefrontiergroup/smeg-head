Feature: Authentication
  In order to be able to use the site
  As a user I
  Want to be able to sign in and out of my account
  
  Scenario: Signing in with valid details
    Given I am signed out
    And I have one user "test@example.com" with user name "sutto" and password "password"
    And I am on the sign in page
    When I fill in "User name or Email" with "test@example.com"
    And I fill in "Password" with "password"
    And I press "Sign In"
    Then I should be signed in
    And I should be on the home page
  
  Scenario: Signing in with invalid details
    Given I am signed out
    And there are no users with the email "test@example.com"
    When I go to the sign in page
    And I fill in "User name or Email" with "test@example.com"
    And I fill in "Password" with "password"
    And I press "Sign In"
    Then I should be on the sign in page
    And I should not be signed in
    
  Scenario: Signing out of my account
    Given I am a new, authenticated user
    When I go to the sign out page
    Then I should not be signed in
    