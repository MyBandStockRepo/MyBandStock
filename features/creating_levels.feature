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
    And I should see "Add a new level"
    When I follow "Add a new level"
    Then I should be on the new level page for "Jason's Awesome Band"
    
  Scenario: create a level
    Given I am logged in as admin user "drew@mbs.com" with password "test123"
    When I go to the levels index page for "Jason's Awesome Band"
    And I follow "Add a new level"
    Then I should be on the new level page for "Jason's Awesome Band"
    When I fill in the following:
    | level_name        | Captain                 |
    | level_points      | 500                     |
    | level_description | The second points level |
    | level_multiplier  | 1.3                     |
    And I press "Save Level"
    Then I should be on the new level reward page for "Captain" and the band "Jason's Awesome Band"
    And I should see "Level Created! Would you like to add rewards for this level?"
    When I fill in the following:
    |reward_name| Dinner with Jason|
    |reward_points| 200|
    |reward_description| you get to go out with Jason |
    |reward_limit|200|
    And I press "Save Reward"
    Then I should be on the new level reward page for "Captain" and the band "Jason's Awesome Band"
    And I should see "New Reward Added!"
    And I should see "Dinner with Jason"
    And I should see "This level has 1 reward"
  
  
  
  
  
  
  
  
  
  
  
  

  
