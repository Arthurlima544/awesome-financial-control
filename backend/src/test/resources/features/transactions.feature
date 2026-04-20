Feature: Last transactions

  Scenario: Get last transactions when no transactions exist
    When I request the last 5 transactions
    Then the response status is 200
    And the transaction list is empty

  Scenario: Get all transactions without a limit parameter
    Given a transaction with description "Alpha" amount 100.00 type INCOME occurred today
    And a transaction with description "Beta" amount 200.00 type EXPENSE occurred 30 days ago
    When I request all transactions
    Then the response status is 200
    And the transaction list has 2 items

  Scenario: Delete an existing transaction returns 204 and removes it
    Given a transaction with description "To delete" amount 50.00 type EXPENSE occurred today
    When I delete the last created transaction
    Then the response status is 204
    And the transaction no longer exists

  Scenario: Delete a non-existing transaction returns 404
    When I delete transaction with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404

  Scenario: Get last N transactions ordered by date descending
    Given a transaction with description "Salary" amount 5000.00 type INCOME occurred today
    And a transaction with description "Groceries" amount 200.00 type EXPENSE occurred today
    And a transaction with description "Old bill" amount 100.00 type EXPENSE occurred 30 days ago
    When I request the last 2 transactions
    Then the response status is 200
    And the transaction list has 2 items
    And the first transaction description is "Salary"
