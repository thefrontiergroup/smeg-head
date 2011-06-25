Feature: SSH Key Management
  In order to control access to my repositories
  As a user I
  Want to be able to manage my ssh public keys
  
  Scenario: Adding a SSH Key
    Given I am signed in
    And I am on the edit profile page
    When I fill in "Name" with "my example key"
    And I fill in "Key" with a valid ssh key
    Then I should be back on the edit profile page
    And I should have a new ssh public key with the name "my example key"
    
  Scenario: Creating a bad SSH Key
    Given I am signed in
    And I am on the edit profile page
    When I fill in "Name" with "my example key"
    And I fill in "Key" with an invalid ssh key
    And I press "Add SSH Public Key"
    Then I should be on the edit users ssh public key page
    And I should "is an invalid key"
    
  Scenario: Remove a SSH Key
    Given I am signed in
    And I have an ssh public key with the name "my example key"
    And I am on the edit profile
    When I press 'Remove' inside the current key
    Then I should not have an ssh public key with the name "my example key"
  
  Scenario: Viewing my SSH keys
    Given I am signed in
    And I have 3 ssh public keys
    And I am on the edit profile page
    Then I should see all of my ssh public keys
  
  
  