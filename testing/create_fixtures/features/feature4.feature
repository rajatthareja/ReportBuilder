Feature: I am some other feature for testing tag functionality

  @high @last
  Scenario: I am some testing scenario with two tags of some functionality
    Given I am give step of some feature
    When I am when step of some other feature
    Then I am then step of some this feature

  @feature
  Scenario: I am some testing scenario with one tags of some functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some other feature

  @high @scenario @feature @more
  Scenario: I am some testing scenario of some functionality
    Given I am give step of some feature
    When I am when step of some feature
    Then I am then step of some feature

  @low
  Scenario:  I am some other testing scenario with watir screenshot
    Given I am give step of some other feature
    When I am when step of some other feature
    And I am step with watir screenshot
    Then I am then step of some other feature

  @high @more @long
  Scenario: I am scenario with more steps
    Given I am give step of some feature
    And I am give step of some other feature
    When I am when step of some feature
    And I am when step of some other feature
    Then I am then step of some feature
    Then I am then step of some other feature