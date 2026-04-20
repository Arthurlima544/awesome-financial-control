Feature: Spending limits management and progress

  Scenario: List all limits when none exist
    When I request all limits
    Then the response status is 200
    And the all-limits list is empty

  Scenario: List all limits returns existing ones
    Given a category named "Alimentação"
    And a spending limit of 500.00 for category "Alimentação"
    Given a category named "Transporte"
    And a spending limit of 300.00 for category "Transporte"
    When I request all limits
    Then the response status is 200
    And the all-limits list has 2 items

  Scenario: Delete an existing limit returns 204 and removes it
    Given a category named "Lazer"
    And a spending limit of 200.00 for category "Lazer"
    When I delete the last created limit
    Then the response status is 204
    And the limit no longer exists

  Scenario: Delete a non-existing limit returns 404
    When I delete limit with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404

  Scenario: Update a limit amount returns updated limit
    Given a category named "Saúde"
    And a spending limit of 100.00 for category "Saúde"
    When I update the last created limit amount to 250.00
    Then the response status is 200
    And the limit amount is 250.00

  Scenario: Update a non-existing limit returns 404
    When I update limit with id "00000000-0000-0000-0000-000000000000" amount to 100.00
    Then the response status is 404

  Scenario: Get limits progress when no limits exist
    When I request the limits progress
    Then the response status is 200
    And the limits list is empty

  Scenario: Limit with no expenses for that category shows zero progress
    Given a category named "Alimentação"
    And a spending limit of 1000.00 for category "Alimentação"
    When I request the limits progress
    Then the response status is 200
    And the limit for "Alimentação" has spent 0.00 and percentage 0.0

  Scenario: Limit progress reflects current month expenses for the matching category
    Given a category named "Transporte"
    And a spending limit of 500.00 for category "Transporte"
    And a transaction with description "Bus pass" amount 200.00 type EXPENSE in category "Transporte" occurred today
    When I request the limits progress
    Then the response status is 200
    And the limit for "Transporte" has spent 200.00 and percentage 40.0

  Scenario: Expenses from a different category are not counted towards the limit
    Given a category named "Lazer"
    And a spending limit of 300.00 for category "Lazer"
    And a transaction with description "Cinema" amount 100.00 type EXPENSE in category "Alimentação" occurred today
    When I request the limits progress
    Then the response status is 200
    And the limit for "Lazer" has spent 0.00 and percentage 0.0

  Scenario: Limit is overspent when expenses exceed the limit amount
    Given a category named "Vestuário"
    And a spending limit of 200.00 for category "Vestuário"
    And a transaction with description "Shoes" amount 350.00 type EXPENSE in category "Vestuário" occurred today
    When I request the limits progress
    Then the response status is 200
    And the limit for "Vestuário" has spent 350.00 and percentage 175.0
