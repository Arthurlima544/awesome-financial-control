Feature: Recurring Transactions management

  Background:
    Given I reset the dev data

  Scenario: Create a recurring transaction rule
    When I create a "MONTHLY" recurring transaction "Rent" with amount 1200.00 in category "Housing" due in 1 days
    Then the response status is 201
    And the response contains "Rent"
    And there are 1 recurring rules

  Scenario: Pending recurring transactions are materialized
    Given I create a "DAILY" recurring transaction "Coffee" with amount 5.00 in category "Food" due in -1 days
    When I process pending recurring transactions
    Then the database has 1 transactions
    And the recurring rule "Coffee" next due date is updated

  Scenario: Inactive rules are not materialized
    Given I create a "DAILY" recurring transaction "Paused" with amount 10.00 in category "Misc" due in -1 days
    And I pause the recurring rule "Paused"
    When I process pending recurring transactions
    Then the database has 0 transactions
