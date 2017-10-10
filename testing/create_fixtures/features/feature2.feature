Feature: I am some other feature for testing some functionality

  @feature
  Scenario: I am some testing scenario of other functionality
    Given I am give step of some feature
    When I am when step of some feature
    Then I am then step of some feature

  @feature
  Scenario Outline: I am some testing scenario outline of other functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some <option> feature
    Examples:
      | option |
      | other  |
      | this   |

  @high
  Scenario: I am some testing scenario of some functionality
    Given I am give step of some feature
    When I am when step which will fail
    Then I am then step of some feature

  @low
  Scenario:  I am some other testing scenario of some functionality
    Given I am give step of some other feature
    When I am when step of some other feature
    Then I am then step of some other feature