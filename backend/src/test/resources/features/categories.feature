Feature: Categories management

  Scenario: List all categories when none exist
    When I request all categories
    Then the response status is 200
    And the category list is empty

  Scenario: List all categories returns existing ones
    Given a category named "Alimentação"
    And a category named "Transporte"
    When I request all categories
    Then the response status is 200
    And the category list has 2 items

  Scenario: Delete an existing category returns 204 and removes it
    Given a category named "Lazer"
    When I delete the last created category
    Then the response status is 204
    And the category no longer exists

  Scenario: Delete a non-existing category returns 404
    When I delete category with id "00000000-0000-0000-0000-000000000000"
    Then the response status is 404

  Scenario: Update a category name returns updated category
    Given a category named "Saude"
    When I update the last created category name to "Saúde"
    Then the response status is 200
    And the category name is "Saúde"

  Scenario: Update a non-existing category returns 404
    When I update category with id "00000000-0000-0000-0000-000000000000" name to "Novo"
    Then the response status is 404

  Scenario: Create a new category returns 201 and the category
    When I create a category named "Saúde"
    Then the response status is 201
    And the category name is "Saúde"

  Scenario: Create a category with empty name returns 422
    When I create a category named ""
    Then the response status is 422

  Scenario: Update a category with empty name returns 422
    Given a category named "Lazer"
    When I update the last created category name to ""
    Then the response status is 422
