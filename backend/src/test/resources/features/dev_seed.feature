Feature: Dev data seeder (local only)

  Scenario: Seed creates categories, limits and transactions
    When I seed the dev data
    Then the response status is 201
    And the database has 6 categories
    And the database has 3 limits
    And the database has 10 transactions

  Scenario: Seed is idempotent and accumulates on repeated calls
    When I seed the dev data
    And I seed the dev data
    Then the database has 12 transactions

  Scenario: Reset clears all data
    Given I seed the dev data
    When I reset the dev data
    Then the response status is 204
    And the database has 0 categories
    And the database has 0 limits
    And the database has 0 transactions

  Scenario: Reset on empty database returns 204
    When I reset the dev data
    Then the response status is 204
