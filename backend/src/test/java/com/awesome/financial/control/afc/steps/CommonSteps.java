package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import org.springframework.beans.factory.annotation.Autowired;

public class CommonSteps {

    @Autowired private ScenarioContext ctx;

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

    @Then("the response status is {int}")
    public void theResponseStatusIs(int status) {
        assertThat(ctx.response.getStatusCode().value()).isEqualTo(status);
    }

    @And("the response contains {string}")
    public void theResponseContains(String content) {
        assertThat((String) ctx.response.getBody()).contains(content);
    }
}
