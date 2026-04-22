Feature: Transaction Templates management

  Background:
    Given I reset the dev data

  Scenario: Create a transaction template
    When I create a template "Lunch" in category "Food" of type "EXPENSE"
    Then the response status is 201
    And the response contains "Lunch"
    And there are 1 templates

  Scenario: Delete a transaction template
    Given I create a template "Salary" in category "Income" of type "INCOME"
    When I delete the last created template
    Then the response status is 204
    And there are 0 templates

  Scenario: List all templates
    Given I create a template "Rent" in category "Housing" of type "EXPENSE"
    And I create a template "Bonus" in category "Income" of type "INCOME"
    When I list all templates
    Then the response status is 200
    And the response contains a list of 2 templates

  Scenario: Try to delete a non-existent template (Exception Handling)
    When I delete a template with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404
    And the response error code is "NOT_FOUND"

  Scenario: Create template with missing description (Validation Error)
    When I create a template "" in category "Food" of type "EXPENSE"
    Then the response status is 422
    And the response error code is "VALIDATION_ERROR"
