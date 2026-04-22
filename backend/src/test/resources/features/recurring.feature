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

  Scenario: Update a recurring transaction rule
    Given I create a "MONTHLY" recurring transaction "Netflix" with amount 45.90 in category "Entertainment" due in 5 days
    When I update the last created recurring rule with amount 55.90
    Then the response status is 200
    And the response contains "55.9"

  Scenario: Delete a recurring transaction rule
    Given I create a "MONTHLY" recurring transaction "Gym" with amount 100.00 in category "Health" due in 10 days
    When I delete the last created recurring rule
    Then the response status is 204
    And there are 0 recurring rules

  Scenario: List all recurring rules
    Given I create a "MONTHLY" recurring transaction "Internet" with amount 150.00 in category "Utilities" due in 15 days
    And I create a "WEEKLY" recurring transaction "Weekly Coffee" with amount 25.00 in category "Food" due in 2 days
    When I list all recurring rules
    Then the response status is 200
    And the response contains "Internet"
    And the response contains "Weekly Coffee"
