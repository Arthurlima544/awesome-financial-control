Feature: Transaction Service Details
  As a user
  I want my transactions to be correctly processed
  So that I can have accurate financial control

  Scenario: Bulk creation of transactions
    When I create the following transactions in bulk:
      | description | amount | type    | category |
      | Item A      | 10.00  | EXPENSE | Food     |
      | Item B      | 20.00  | EXPENSE | Food     |
    Then the response status is 201
    And the transaction list has 2 items

  Scenario: Auto-matching transaction to recurring rule
    Given a recurring transaction with description "Rent" amount 1200.00 type EXPENSE category "Housing" frequency MONTHLY
    When I create a transaction with description "Monthly Rent" amount 1200.00 type EXPENSE category "Housing" occurred today
    Then the response status is 201
    And the recurring transaction "Rent" should be marked as paid today

  Scenario: Auto-matching transaction to recurring rule with similar amount
    Given a recurring transaction with description "Electricity" amount 100.00 type EXPENSE category "Utilities" frequency MONTHLY
    When I create a transaction with description "Electric Bill" amount 105.00 type EXPENSE category "Utilities" occurred today
    Then the response status is 201
    And the recurring transaction "Electricity" should be marked as paid today

  Scenario: Get current month summary
    Given a transaction with description "Income" amount 3000.00 type INCOME occurred today
    And a transaction with description "Expense" amount 1000.00 type EXPENSE occurred today
    When I request the current month summary
    Then the response status is 200
    And the summary total income is 3000.00
    And the summary total expenses is 1000.00
    And the summary balance is 2000.00

  Scenario: Transaction does not match recurring rule due to different category
    Given a recurring transaction with description "Rent" amount 1200.00 type EXPENSE category "Housing" frequency MONTHLY
    When I create a transaction with description "Monthly Rent" amount 1200.00 type EXPENSE category "Food" occurred today
    Then the response status is 201
    And the recurring transaction "Rent" should not be marked as paid

  Scenario: Transaction does not match recurring rule due to different amount
    Given a recurring transaction with description "Electricity" amount 100.00 type EXPENSE category "Utilities" frequency MONTHLY
    When I create a transaction with description "Big Electric Bill" amount 150.00 type EXPENSE category "Utilities" occurred today
    Then the response status is 201
    And the recurring transaction "Electricity" should not be marked as paid
