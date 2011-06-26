Feature: User Repository Management
  In order to interact with git
  As a user I
  Want to be able to create and manage repositories
  
  Scenario: Creating a new valid repository
    Given I am a new, authenticated user with the user name "sutto"
    When I go to the new user repository page
    When I fill in the following:
      | Name        | Totally not a gaming site                      |
      | Description | This repository does not contain a gaming site |
    And I press "Create Repository"
    Then I should have a new repository with the name "Totally not a gaming site"
    And I should be on the page for the "sutto/totally-not-a-gaming-site" repository
  
  Scenario: Attempting to create an invalid repository
    Given I am a new, authenticated user with the user name "sutto"
    And I am on the new user repository page
    When I fill in the following:
      | Description | Use the force, Luke. |
    And I press "Create Repository"
    Then I should not have a repository with the description "Use the force, Luke."
    And I should be on the create user repository page
    
  
  Scenario: Editing a repositories details
    Given I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And I am editing the current repository
    When I fill in "Description" with "this is a repository of doom..."
    And I press "Update Repository"
    Then I should be editing the current repository
    And the current repository's description should be "this is a repository of doom..."
  
  Scenario: Removing a repository
    Given I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And I am editing the current repository
    When I press "Remove this Repository"
    Then the current repository should no longer exist
    And I should be on the home page