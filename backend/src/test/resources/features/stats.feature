Feature: Monthly financial statistics

  Scenario: Returns 6 months of zeros when there are no transactions
    When I request the monthly stats
    Then the response status is 200
    And the stats response contains 6 months
    And the current month income is 0.00
    And the current month expenses is 0.00

  Scenario: Current month income and expenses are correctly aggregated
    Given a transaction with description "Salary" amount 5000.00 type INCOME occurred today
    And a transaction with description "Rent" amount 1500.00 type EXPENSE occurred today
    When I request the monthly stats
    Then the response status is 200
    And the current month income is 5000.00
    And the current month expenses is 1500.00

  Scenario: Multiple income transactions in current month are summed
    Given a transaction with description "Salary" amount 3000.00 type INCOME occurred today
    And a transaction with description "Freelance" amount 1200.00 type INCOME occurred today
    When I request the monthly stats
    Then the response status is 200
    And the current month income is 4200.00

  Scenario: Transactions from previous month appear in their own slot and not in current month
    Given a transaction with description "Old salary" amount 4000.00 type INCOME occurred in the previous month
    When I request the monthly stats
    Then the response status is 200
    And the current month income is 0.00
    And the prior month income is 4000.00
