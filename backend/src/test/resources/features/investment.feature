@Investment
Feature: Investment portfolio management

  Background:
    Given the database is clean

  Scenario: Create a new investment
    When I create an investment with name "Petrobras", ticker "PETR4", type "STOCK", quantity 100, and avg cost 35.0
    Then the response status is 201
    And the response should contain investment name "Petrobras" and total cost 3500.0

  Scenario: Update investment price and calculate gain/loss
    Given I have an investment with name "Bitcoin", ticker "BTC", type "CRYPTO", quantity 0.5, and avg cost 40000.0
    When I update the price of "Bitcoin" to 60000.0
    Then the response status is 200
    And the investment "Bitcoin" current value should be 30000.0
    And the investment "Bitcoin" gain loss should be 10000.0
    And the investment "Bitcoin" gain loss percentage should be 50.0%

  Scenario: List investments
    Given I have an investment with name "Fixed 1", ticker "", type "FIXED_INCOME", quantity 1, and avg cost 1000.0
    And I have an investment with name "Fixed 2", ticker "", type "FIXED_INCOME", quantity 1, and avg cost 2000.0
    When I request all investments
    Then the response status is 200
    And the investments list has 2 items
