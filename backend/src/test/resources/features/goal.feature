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
