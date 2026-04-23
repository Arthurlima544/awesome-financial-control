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

  Scenario: Create investment with invalid data returns 422
    When I create an investment with name "", ticker "", type "STOCK", quantity -10, and avg cost 0.0
    Then the response status is 422

  Scenario: Update investment price with invalid value returns 422
    Given I have an investment with name "Gold", ticker "GOLD", type "OTHER", quantity 10, and avg cost 100.0
    When I update the price of "Gold" to -5.0
    Then the response status is 422

  Scenario: Update investment price
    Given I have an investment "PETR4" price 35.0 quantity 100
    When I update "PETR4" price to 40.0
    Then the response status is 200
    And the investment "PETR4" current value should be 4000.0

  Scenario: Update price of a non-existing investment returns 404
    When I update investment with id "00000000-0000-0000-0000-000000000000" price to 100.0
    Then the response status is 404

  Scenario: Delete an investment
    Given I have an investment "VALE3" price 70.0 quantity 50
    When I delete investment "VALE3"
    Then the response status is 204
    And the investment "VALE3" should not exist

  Scenario: Delete a non-existing investment returns 404
    When I delete investment with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404
