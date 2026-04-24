@Calculator
Feature: Financial calculators

  Scenario: Calculate FIRE number and timeline
    When I calculate FIRE with:
      | monthlyExpenses | 5000.0 |
      | currentPortfolio | 100000.0 |
      | monthlySavings | 2000.0 |
      | annualReturnRate | 0.07 |
      | safeWithdrawalRate | 0.04 |
    Then the response status is 200
    And the FIRE number should be 1500000.0
    And the months to FIRE should be greater than 0
    And the yearly timeline should not be empty
