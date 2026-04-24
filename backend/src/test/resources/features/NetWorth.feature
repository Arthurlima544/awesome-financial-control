Feature: Net Worth Evolution
  As a user
  I want to see my net worth evolution over time
  To track my financial growth

  Background:
    Given the database is empty

  Scenario: Calculate net worth evolution with transactions and investments
    Given a category "Salário" exists
    And a transaction "Salário" of 5000.00 type "INCOME" occurred at "2024-01-15T10:00:00Z"
    And a transaction "Aluguel" of 2000.00 type "EXPENSE" occurred at "2024-01-20T10:00:00Z"
    And an investment "Petrobras" ticker "PETR4" type "STOCK" quantity "10" avgCost "30.00" price "35.00" created at "2024-02-10T10:00:00Z"
    When I request the net worth evolution
    Then I should receive 12 data points
    And the point for "2024-01" should have assets 3000.00
    And the point for "2024-02" should have assets 3350.00
