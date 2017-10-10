Feature: I am some feature for testing some functionality

  @high
  Scenario: I am some testing scenario of some functionality
    Given I am give step of some feature
    When I am when step of some feature
    Then I am then step of some feature

  @low
  Scenario:  I am some other testing scenario of some functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some other feature

  @high @last
  Scenario: I am some testing scenario with two tags of some functionality
    Given I am give step of some feature
    When I am when step of some other feature
    Then I am then step of some this feature

  @feature
  Scenario: I am some testing scenario of other functionality
    Given I am give step of some feature
    When I am when step of some feature
    Then I am then step of some feature