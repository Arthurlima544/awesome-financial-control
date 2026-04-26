package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.GoalRequest;
import com.awesome.financial.control.afc.dto.GoalResponse;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.repository.GoalRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class GoalSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final GoalRepository goalRepository;

    @After
    public void cleanUp() {
        goalRepository.deleteAll();
    }

    @When("I create a goal with name {string}, target {double}, and deadline {string}")
    public void iCreateAGoalWithNameTargetAndDeadline(String name, double target, String deadline) {
        GoalRequest request =
                GoalRequest.builder()
                        .name(name)
                        .targetAmount(BigDecimal.valueOf(target))
                        .currentAmount(BigDecimal.ZERO)
                        .deadline(Instant.parse(deadline + "T00:00:00Z"))
                        .build();
        ResponseEntity<GoalResponse> response =
                restTemplate.postForEntity("/api/v1/goals", request, GoalResponse.class);
        context.response = response;
        if (response.getBody() != null) {
            context.lastGoalId = response.getBody().id();
        }
    }

    @And("the response should contain goal name {string} and target {double}")
    public void theResponseShouldContainGoalNameAndTarget(String name, double target) {
        GoalResponse body = (GoalResponse) context.response.getBody();
        assertThat(body.name()).isEqualTo(name);
        assertThat(body.targetAmount()).isEqualByComparingTo(BigDecimal.valueOf(target));
    }

    @Given(
            "I have a goal with name {string}, target {double}, current {double}, and deadline {string}")
    public void iHaveAGoalWithNameTargetCurrentAndDeadline(
            String name, double target, double current, String deadline) {
        Goal goal = new Goal();
        goal.setName(name);
        goal.setTargetAmount(BigDecimal.valueOf(target));
        goal.setCurrentAmount(BigDecimal.valueOf(current));
        goal.setDeadline(Instant.parse(deadline + "T00:00:00Z"));
        context.lastGoalId = goalRepository.save(goal).getId();
    }

    @When("I add a contribution of {double} to the {string} goal")
    public void iAddAContributionOfToTheGoal(double amount, String name) {
        ResponseEntity<GoalResponse> response =
                restTemplate.exchange(
                        "/api/v1/goals/" + context.lastGoalId + "/contribute?amount=" + amount,
                        HttpMethod.PATCH,
                        null,
                        GoalResponse.class);
        context.response = response;
    }

    @And("the goal {string} current amount should be {double}")
    public void theGoalCurrentAmountShouldBe(String name, double expected) {
        GoalResponse body = (GoalResponse) context.response.getBody();
        assertThat(body.currentAmount()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the goal {string} progress should be {double}%")
    public void theGoalProgressShouldBe(String name, double expected) {
        GoalResponse body = (GoalResponse) context.response.getBody();
        assertThat(body.progressPercentage()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @When("I request all goals")
    public void iRequestAllGoals() {
        context.response = restTemplate.getForEntity("/api/v1/goals", String.class);
    }

    @And("the goals list has {int} items")
    public void theGoalsListHasItems(int count) {
        String body = (String) context.response.getBody();
        long commaCount = body.chars().filter(c -> c == '{').count();
        assertThat(commaCount).isEqualTo(count);
    }

    @When("I update goal with name {string} to have target {double}")
    public void iUpdateGoalWithNameToHaveTarget(String name, double target) {
        GoalRequest request =
                GoalRequest.builder()
                        .name(name)
                        .targetAmount(BigDecimal.valueOf(target))
                        .deadline(Instant.now().plusSeconds(86400 * 30))
                        .currentAmount(BigDecimal.ZERO)
                        .build();
        context.response =
                restTemplate.exchange(
                        "/api/v1/goals/" + context.lastGoalId,
                        HttpMethod.PUT,
                        new HttpEntity<>(request),
                        GoalResponse.class);
    }

    @And("the goal {string} target should be {double}")
    public void theGoalTargetShouldBe(String name, double expected) {
        GoalResponse body = (GoalResponse) context.response.getBody();
        assertThat(body.targetAmount()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @When("I update goal with id {string} with name {string} target {double} deadline {string}")
    public void iUpdateGoalWithId(String id, String name, double target, String deadline) {
        GoalRequest request =
                GoalRequest.builder()
                        .name(name)
                        .targetAmount(BigDecimal.valueOf(target))
                        .currentAmount(BigDecimal.ZERO)
                        .deadline(Instant.parse(deadline + "T00:00:00Z"))
                        .build();
        context.response =
                restTemplate.exchange(
                        "/api/v1/goals/" + id,
                        HttpMethod.PUT,
                        new HttpEntity<>(request),
                        String.class);
    }

    @When("I delete goal with id {string}")
    public void iDeleteGoalWithId(String id) {
        context.response =
                restTemplate.exchange("/api/v1/goals/" + id, HttpMethod.DELETE, null, String.class);
    }
}
