Feature: Investment Goal Calculator
  As a user
  I want to calculate how much I need to invest monthly to reach my goal
  So that I can plan my financial future

  Scenario: Calculate required monthly contribution
    When I request an investment goal calculation with:
      | targetAmount     | 1000000              |
      | targetDate       | 2036-01-01           |
      | annualReturnRate | 0.10                 |
      | initialAmount    | 0                    |
    Then the response status is 200
    And the required monthly contribution is greater than 4000
    And the total contributed is less than 1000000
    And the timeline has entries
