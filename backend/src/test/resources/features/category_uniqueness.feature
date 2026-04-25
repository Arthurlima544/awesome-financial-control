Feature: Category Uniqueness
  As a user
  I want category names to be unique regardless of case and accents
  So that I don't have duplicate categories

  Background:
    Given I request all categories
    And the category list is empty

  Scenario: Create categories with similar names
    When I create a category named "Saúde"
    Then the status code is 201
    And the category name is "Saúde"
    
    When I create a category named "saude"
    Then the status code is 409

    When I create a category named "SAÚDE"
    Then the status code is 409

    When I create a category named "Sáude"
    Then the status code is 409

  Scenario: Update category to a name that already exists
    When I create a category named "Alimentação"
    Then the status code is 201
    When I create a category named "Lazer"
    Then the status code is 201
    
    When I update the last created category name to "alimentacao"
    Then the status code is 409
