@Feedback
Feature: User Feedback
  As a user
  I want to be able to send feedback about the application
  So that I can help improve the product

  Background:
    Given the database is clean

  Scenario: Submit feedback successfully
    When I submit feedback with:
      | rating     | 5               |
      | message    | Great app!      |
      | appVersion | 1.0.0           |
      | platform   | Android         |
    Then the response status is 201
    And the feedback response should contain:
      | rating     | 5               |
      | message    | Great app!      |
      | appVersion | 1.0.0           |
      | platform   | Android         |

  Scenario: Submit feedback without message
    When I submit feedback with:
      | rating     | 4               |
      | appVersion | 1.0.1           |
      | platform   | iOS             |
    Then the response status is 201
    And the feedback response should contain:
      | rating     | 4               |
      | appVersion | 1.0.1           |
      | platform   | iOS             |

  Scenario Outline: Submit feedback with invalid rating
    When I submit feedback with:
      | rating     | <rating>        |
      | appVersion | 1.0.0           |
      | platform   | Android         |
    Then the response status is 422
    And the response should contain "VALIDATION_ERROR"

    Examples:
      | rating |
      | 0      |
      | 6      |

  Scenario: Submit feedback with missing required fields
    When I submit feedback with:
      | rating     | 5               |
    Then the response status is 422
    And the response should contain "VALIDATION_ERROR"
