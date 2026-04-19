Feature: Financial summary

  Scenario: Get current month summary with no transactions
    When I request the financial summary
    Then the response status is 200
    And the total income is 0
    And the total expenses is 0
    And the balance is 0

  Scenario: Get current month summary with income and expense transactions
    Given a transaction with description "Salary" amount 5000.00 type INCOME occurred today
    And a transaction with description "Rent" amount 1500.00 type EXPENSE occurred today
    When I request the financial summary
    Then the response status is 200
    And the total income is 5000.00
    And the total expenses is 1500.00
    And the balance is 3500.00
