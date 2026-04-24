@Calculator
Feature: Compound Interest Simulator

  Scenario: Calculate compound interest with monthly contributions
    When I calculate compound interest with:
      | initialAmount        | 1000  |
      | monthlyContribution | 100   |
      | years               | 10    |
      | annualInterestRate  | 0.10  |
    Then the final amount should be approximately 22580.13
    And the total invested should be 13000.00
    And the total interest should be approximately 9580.13
    And the compound interest timeline should have 11 entries
