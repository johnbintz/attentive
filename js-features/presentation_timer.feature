Feature: Presentation Timer
  Background:
    Given I have a presentation counter

  Scenario: Render
    When I render the counter
    Then the counter should show the time "00:00"
      And the counter should not be running

  Scenario: Manage the timer
    When I start the timer
    Then the counter should be running
    When I stop the timer
    Then the counter should not be running

