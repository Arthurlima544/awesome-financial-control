@PassiveIncome
Feature: Passive Income Tracking

  Scenario: Get passive income dashboard
    Given I have the following investments:
      | name  | ticker | type  | quantity | avgCost | currentPrice |
      | Petro | PETR4  | STOCK | 100      | 30.0    | 35.0         |
    And I have the following transactions:
      | description | amount | type   | category    | occurredAt | isPassive | ticker |
      | Dividendos  | 150.0  | INCOME | Dividendos  | 2026-04-10 | true      | PETR4  |
      | Aluguel     | 1200.0 | INCOME | Aluguel     | 2026-04-12 | true      |        |
      | Mercado     | 1000.0 | EXPENSE| Alimentação | 2026-04-15 | false     |        |
    When I get the passive income dashboard
    Then the total passive income should be 1350.00
    And the total expenses should be 1000.00
    And the freedom index should be 100.00
    And the income from "PETR4" should be 150.00
