@Investment
Feature: Investment Dashboard

  Scenario: Get investment dashboard with mixed assets
    Given I have the following investments:
      | name       | ticker | type         | quantity | avgCost | currentPrice |
      | Apple      | AAPL   | STOCK        | 10       | 150.00  | 180.00       |
      | Bitcoin    | BTC    | CRYPTO       | 0.1      | 30000.0 | 40000.0      |
      | Tesouro    | TD     | FIXED_INCOME | 1        | 5000.0  | 5500.0       |
    When I get the investment dashboard
    Then the dashboard total invested should be 9500.00
    And the current total value should be 11300.00
    And the total profit should be 1800.00
    And the allocation for "STOCK" should be 1800.00
    And the allocation for "CRYPTO" should be 4000.00
    And the allocation for "FIXED_INCOME" should be 5500.00
    And the performance list should have 3 assets
