package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

public class CommonSteps {

    @Autowired private ScenarioContext ctx;
    @Autowired private TestRestTemplate restTemplate;

    @Autowired
    private com.awesome.financial.control.afc.repository.TransactionRepository
            transactionRepository;

    @Autowired
    private com.awesome.financial.control.afc.repository.FeedbackRepository feedbackRepository;

    @io.cucumber.java.en.Given("the database is clean")
    public void theDatabaseIsClean() {
        transactionRepository.deleteAll();
        feedbackRepository.deleteAll();
    }

    @When("I send a POST request to {string} with malformed JSON")
    public void iSendPostRequestWithMalformedJson(String url) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>("{invalid json", headers);
        ctx.response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
    }

    @Then("the response status is {int}")
    public void theResponseStatusIs(int status) {
        assertThat(ctx.response.getStatusCode().value()).isEqualTo(status);
    }

    @Then("the response should contain {string}")
    @And("the response contains {string}")
    public void theResponseShouldContain(String content) {
        Object body = ctx.response.getBody();
        if (body instanceof String) {
            assertThat((String) body).contains(content);
        } else if (body != null) {
            assertThat(body.toString()).contains(content);
        } else {
            throw new AssertionError("Response body is null");
        }
    }
}
