Feature: I am some other feature for testing some broken functionality

  @scenario @screenshot
  Scenario: I am some failed testing scenario of some functionality
    Given I am give step of some feature
    When I am when step which will fail
    Then I am then step of some feature

  @wip
  Scenario: I am some undefined testing scenario of some functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some undefined feature

  @scenario
  Scenario: I am some pending testing scenario of some functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some pending feature

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