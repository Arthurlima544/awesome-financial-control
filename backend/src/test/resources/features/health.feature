Feature: Financial Health Score
  As a user, I want to see my financial health score
  So that I can understand my financial situation

  Scenario: Get health score when no data exists
    When I request the financial health score
    Then the response status is 200
    And the health score is 75
    And the historical scores list has 6 items

  Scenario: Get health score with transactions and limits
    Given a category named "Alimentação"
    And a spending limit of 1000.0 for category "Alimentação"
    And a transaction with description "Lunch" amount 200.0 type EXPENSE occurred today
    And a transaction with description "Salary" amount 5000.0 type INCOME occurred today
    When I request the financial health score
    Then the response status is 200
    And the health score should be greater than 75
    And the historical scores list has 6 items
