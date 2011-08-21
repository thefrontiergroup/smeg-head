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
    
  Scenario: Viewing a repositories collaborators
    Given I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And the current repository has the collaborators:
      | user_name |
      | tissak    |
      | sj26      |
      | ruxton    |
    And I am editing the current repository
    Then I should see 3 collaborators
    And I should see a collaborator with the user name "tissak"
    And I should see a collaborator with the user name "sj26"
    And I should see a collaborator with the user name "ruxton"
    
  
  Scenario: Adding a collaborator to a repository
    Given there is a user with the user name "sj26"
    And I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And I am editing the current repository
    When I fill in "Collaborator Name" with "sj26"
    And I press "Add" within the collaborator form
    Then I should be editing the current repository
    And I should see 1 collaborator
    And I should see a collaborator with the user name "sj26"
    
  
  Scenario: Adding an invalid collaborator to a repository
    Given I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And I am editing the current repository
    When I fill in "Collaborator Name" with "non-existant-user"
    And I press "Add" within the collaborator form
    Then I should be on the create collaborator page for the current repository
    And I should see errors on the collaboration user name
    
  
  Scenario: Removing a collaborator from a repository
    Given I am a new, authenticated user with the user name "sutto"
    And I have a repository with the name "Test Repository"
    And the current repository has the collaborators:
      | user_name |
      | sj26      |
    And I am editing the current repository
    When I press "Remove" within the collaborator "sj26"
    Then I should be editing the current repository
    And I should see 0 collaborators