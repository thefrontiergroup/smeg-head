Feature: SSH Key Management
  In order to control access to my repositories
  As a user I
  Want to be able to manage my ssh public keys
  
  Scenario: Adding a SSH Key
    Given I am a new, authenticated user
    And I am on the edit profile page
    When I fill in "Name" with "my example key"
    And I fill in "Key" with a valid ssh key
    And I press "Add SSH Public Key"
    Then I should be on the edit profile page
    And I should have a new ssh public key with the name "my example key"
    
  Scenario: Creating a bad SSH Key
    Given I am a new, authenticated user
    And I am on the edit profile page
    When I fill in "Name" with "my example key"
    And I fill in "Key" with an invalid ssh key
    And I press "Add SSH Public Key"
    Then I should be on the users ssh public keys page
    And I should see errors on the ssh key contents
    
  Scenario: Remove a SSH Key
    Given I am a new, authenticated user
    And I have a ssh public key with the name "my example key"
    And I am on the edit profile page
    When I press "Remove" within the current ssh public key
    Then I should not have an ssh public key with the name "my example key"
  
  Scenario: Viewing my SSH keys
    Given I am a new, authenticated user
    And I have a ssh public key with the name "Test Key A"
    And I have a ssh public key with the name "Test Key B"
    And I have a ssh public key with the name "Test Key C"
    When I go to the edit profile page
    Then I should see a ssh public key named "Test Key A"
    And I should see a ssh public key named "Test Key B"
    And I should see a ssh public key named "Test Key C"
  
  
  