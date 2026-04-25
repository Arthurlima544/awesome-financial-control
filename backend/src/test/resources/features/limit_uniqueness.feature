Feature: Limit Uniqueness
  As a user
  I want to have only one spending limit per category
  So that I don't have duplicate budget goals

  Background:
    Given I request all limits
    And the all-limits list is empty

  Scenario: Create multiple limits for the same category
    Given a category named "Lazer"
    When I create a limit of 500 for the last created category
    Then the status code is 201
    
    When I create a limit of 300 for the last created category
    Then the status code is 409
    And the all-limits list has 1 items
