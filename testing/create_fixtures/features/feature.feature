Feature: This is a feature with table in step

  Background:
    Given I am give step of some feature

  @feature
  Scenario: I have table in one of my step
    When I am step with options:
      | option1 | value1 |
      | option2 | value2 |
    Then I am then step of some feature

  @high
  Scenario: I am some testing scenario of some functionality
    When I am when step of some feature
    Then I am then step of some feature

  @low
  Scenario:  I am some other testing scenario of some functionality
    And I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some other feature

  @feature
  Scenario: I am some testing scenario of other functionality
    When I am when step of some feature
    And I am when step which will fail
    Then I am then step of some feature
