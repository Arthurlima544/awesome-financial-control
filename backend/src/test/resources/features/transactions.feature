Feature: Last transactions

  Scenario: Get last transactions when no transactions exist
    When I request the last 5 transactions
    Then the response status is 200
    And the transaction list is empty

  Scenario: Get last N transactions ordered by date descending
    Given a transaction with description "Salary" amount 5000.00 type INCOME occurred today
    And a transaction with description "Groceries" amount 200.00 type EXPENSE occurred today
    And a transaction with description "Old bill" amount 100.00 type EXPENSE occurred 30 days ago
    When I request the last 2 transactions
    Then the response status is 200
    And the transaction list has 2 items
    And the first transaction description is "Salary"
