Feature: Creating levels
  In order to have levels for artists
  As an MBS admin
  I want to be able to add levels
  
  Background:
  Given there is a band in the system named "Jason's Awesome Band"
  And an admin user in the system with the email "drew@mbs.com" and password "test123"
  
  Scenario: access denied
    Given I am not logged in
    When I go to the new level page for "Jason's Awesome Band"
    Then I should be on the sign in page
    When I go to the levels index page for "Jason's Awesome Band"
    Then I should be on the levels index page for "Jason's Awesome Band"
    And I should not see "Add New Level"
  
  Scenario: access granted
    Given I am logged in as admin user "drew@mbs.com" with password "test123"
    Then I should see "levels and rewards"
    When I follow "levels and rewards"
    Then I should be on the levels index page for "Jason's Awesome Band"
    And I should see "Add New Level"
    When I go to the new level page for "Jason's Awesome Band"
    Then I should be on the new level page for "Jason's Awesome Band"
    And I should see "Add a new level"
    When I follow "Add a new level"
    Then I should be on the new level page for "Jason's Awesome Band"  
  
    
  Scenario: create a level
    Given I am logged in as admin user "drew@mbs.com" with password "test123"
    And I am on the new level page for "Jason's Awesome Band"
    When I fill in the following:
    |||
    |||
    |||
    |||
    And I press "Save Level"
    Then I should be on the new reward page for "Level 1" and the band "Jason's Awesome Band"
    And I should see "Level Created! Would you like to add rewards for this level?"
    And I should see "Add another level"
    When I fill in the following:
    |||
    |||
    |||
    |||
    |||
    And I press "Save Reward"
    Then I should be on the new reward page for "Level 1"
    And I should see "New Reward Added!"
    And I should see "Reward title"
    And I should see "This level has 1 reward"
  
  
  
  
  
  
  
  
  
  
  
  

  
