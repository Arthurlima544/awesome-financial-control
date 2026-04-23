Feature: Bulk Transaction Import
  
  Scenario: Import multiple transactions successfully
    When I import the following transactions:
      | description | amount | type    | category | occurredAt               |
      | Salary      | 5000.0 | INCOME  | Work     | 2026-02-01T10:00:00.000Z |
      | Rent        | 1500.0 | EXPENSE | Home     | 2026-02-02T10:00:00.000Z |
    Then the response status is 201
    And I request all transactions
    And the transaction list has 2 items
    And the transaction list contains description "Salary" with amount 5000.0
    And the transaction list contains description "Rent" with amount 1500.0

  Scenario: Import transactions with invalid data returns 400
    When I import an invalid bulk request
    Then the response status is 400

  Scenario: Import transactions with a negative amount in bulk returns 422
    When I import the following transactions:
      | description | amount | type   | category | occurredAt               |
      | Valid       | 100.0  | INCOME | Work     | 2026-02-01T10:00:00.000Z |
      | Invalid     | -50.0  | EXPENSE| Home     | 2026-02-02T10:00:00.000Z |
    Then the response status is 422

  Scenario: Import an empty list returns 201 and does nothing
    When I import an empty list of transactions
    Then the response status is 201
    And I request all transactions
    And the transaction list is empty
