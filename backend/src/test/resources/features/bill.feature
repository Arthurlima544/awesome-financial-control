Feature: Bill Reminders Management
  As a user, I want to manage my monthly bills
  So that I can keep track of my upcoming payments

  Scenario: Create and list bills
    When I create a bill with name "Aluguel", amount 1500.00 and due day 10
    Then the bill list should contain "Aluguel" with amount 1500.00 and due day 10

  Scenario: Update a bill
    Given a bill "Internet" with amount 120.00 and due day 15 exists
    When I update the bill "Internet" to amount 130.00 and due day 20
    Then the bill list should contain "Internet" with amount 130.00 and due day 20

  Scenario: Delete a bill
    Given a bill "Spotify" with amount 21.90 and due day 5 exists
    When I delete the bill "Spotify"
    Then the bill list should not contain "Spotify"
