@Report
Feature: Monthly Reporting
  As a user
  I want to see a detailed breakdown of my spending
  So that I can better manage my finances

  Background:
    Given the database is clean

  Scenario: Get detailed monthly report
    Given a transaction with description "Salary", amount 5000.0, type "INCOME", and category "Salary" for "2024-03"
    And a transaction with description "Rent", amount 1500.0, type "EXPENSE", and category "Housing" for "2024-03"
    And a transaction with description "Groceries", amount 500.0, type "EXPENSE", and category "Food" for "2024-03"
    And a transaction with description "Dining Out", amount 200.0, type "EXPENSE", and category "Food" for "2024-03"
    And a transaction with description "Previous Rent", amount 1500.0, type "EXPENSE", and category "Housing" for "2024-02"
    When I request the monthly report for "2024-03"
    Then the response should contain:
      | totalIncome   | 5000.0 |
      | totalExpenses | 2200.0 |
      | savingsRate   | 56.0   |
    And the category "Food" should have amount 700.0
    And the category "Housing" should have amount 1500.0
    And the category "Housing" comparison should show current 1500.0 and previous 1500.0
    And the category "Food" comparison should show current 700.0 and previous 0.0

  Scenario: Handle uncategorized transactions in comparison
    Given a transaction with description "Other", amount 100.0, type "EXPENSE", and category "null" for "2024-03"
    And a transaction with description "Other Prev", amount 50.0, type "EXPENSE", and category "null" for "2024-02"
    When I request the monthly report for "2024-03"
    Then the response status is 200
    And the category comparison for null should show current 100.0 and previous 50.0
