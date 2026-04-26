@Goal
Feature: Savings Goals management

  Background:
    Given the database is clean

  Scenario: Create a new savings goal
    When I create a goal with name "Emergency Fund", target 10000.0, and deadline "2026-12-31"
    Then the response status is 201
    And the response should contain goal name "Emergency Fund" and target 10000.0

  Scenario: Add contribution to a goal
    Given I have a goal with name "Travel", target 5000.0, current 1000.0, and deadline "2025-12-31"
    When I add a contribution of 500.0 to the "Travel" goal
    Then the response status is 200
    And the goal "Travel" current amount should be 1500.0
    And the goal "Travel" progress should be 30.0%

  Scenario: List goals
    Given I have a goal with name "Goal 1", target 100.0, current 10.0, and deadline "2025-01-01"
    And I have a goal with name "Goal 2", target 200.0, current 20.0, and deadline "2025-01-01"
    When I request all goals
    Then the response status is 200
    And the goals list has 2 items

  Scenario: Create a goal with invalid data returns 422
    When I create a goal with name "", target -100.0, and deadline "2026-12-31"
    Then the response status is 422

  Scenario: Add a negative contribution returns 422
    Given I have a goal with name "Travel", target 5000.0, current 1000.0, and deadline "2025-12-31"
    When I add a contribution of -50.0 to the "Travel" goal
    Then the response status is 422

  Scenario: Update a goal
    Given I have a goal with name "Savings", target 1000.0, current 100.0, and deadline "2025-12-31"
    When I update goal with name "Savings" to have target 1500.0
    Then the response status is 200
    And the goal "Savings" target should be 1500.0

  Scenario: Update a non-existing goal returns 404
    When I update goal with id "00000000-0000-0000-0000-000000000000" with name "Novo" target 100.0 deadline "2026-12-31"
    Then the response status is 404

  Scenario: Delete a non-existing goal returns 404
    When I delete goal with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404

  Scenario: Delete a goal
    Given I have a goal with name "Emergency Fund", target 10000.0, current 0.0, and deadline "2026-12-31"
    When I delete the last created goal
    Then the response status is 204

  Scenario: Add contribution to non-existing goal returns 404
    When I add a contribution of 100.0 to goal with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404

  Scenario: Send malformed JSON to create a goal returns 400
    When I send a POST request to "/api/v1/goals" with malformed JSON
    Then the response status is 400
    And the response should contain "Malformed JSON request"
