package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.HealthScoreResponse;
import io.cucumber.java.en.And;
import io.cucumber.java.en.When;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class HealthScoreSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;

    @When("I request the financial health score")
    public void iRequestTheFinancialHealthScore() {
        ResponseEntity<HealthScoreResponse> response =
                restTemplate.getForEntity("/api/v1/health/score", HealthScoreResponse.class);
        context.response = response;
    }

    @And("the health score is {int}")
    public void theHealthScoreIs(int expected) {
        HealthScoreResponse body = (HealthScoreResponse) context.response.getBody();
        assertThat(body.score()).isEqualTo(expected);
    }

    @And("the historical scores list has {int} items")
    public void theHistoricalScoresListHasItems(int count) {
        HealthScoreResponse body = (HealthScoreResponse) context.response.getBody();
        assertThat(body.historicalScores()).hasSize(count);
    }

    @And("the health score should be greater than {int}")
    public void theHealthScoreShouldBeGreaterThan(int min) {
        HealthScoreResponse body = (HealthScoreResponse) context.response.getBody();
        assertThat(body.score()).isGreaterThan(min);
    }
}
