Feature: Market Opportunities Feed
  As an investor
  I want to see curated stock and FII opportunities
  So that I can make better investment decisions

  Background:
    Given the market data cache is empty

  Scenario: Retrieve market opportunities for the first time
    Given the Brapi API returns data
    When I request the market opportunities
    Then the response should contain a list of stocks and FIIs
    And the data should be persisted in the database
    And each opportunity should have a "lastUpdated" timestamp

  Scenario: Serve data from database when market is closed
    Given the market is closed in Brasilia
    And there are market opportunities persisted in the database
    When I request the market opportunities
    Then the response should contain the persisted data
    And no calls should be made to the Brapi API

  Scenario: Refresh data when market is open and cache is stale
    Given the market is open in Brasilia
    And the persisted market data is older than 1 hour
    And the Brapi API returns data
    When I request the market opportunities
    Then the data should be refreshed from the Brapi API
    And the new data should be saved to the database

  Scenario: Get market benchmarks returns CDI and Selic rates
    When I request the market benchmarks
    Then the response status is 200
    And the response should contain "cdiRate"
    And the response should contain "selicRate"
