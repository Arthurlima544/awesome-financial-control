package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpMethod;

public class DevSeedSteps {

    @Autowired private TestRestTemplate restTemplate;
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private LimitRepository limitRepository;
    @Autowired private CategoryRepository categoryRepository;
    @Autowired private ScenarioContext ctx;

    @After
    public void cleanUp() {
        transactionRepository.deleteAll();
        limitRepository.deleteAll();
        categoryRepository.deleteAll();
    }

    @Given("I seed the dev data")
    public void iSeedTheDevData() {
        ctx.response = restTemplate.postForEntity("/api/v1/dev/seed", null, String.class);
    }

    @When("I reset the dev data")
    public void iResetTheDevData() {
        ctx.response =
                restTemplate.exchange("/api/v1/dev/reset", HttpMethod.DELETE, null, String.class);
    }

    @And("the database has {int} categories")
    public void theDatabaseHasCategories(int count) {
        assertThat(categoryRepository.count()).isEqualTo(count);
    }

    @And("the database has {int} limits")
    public void theDatabaseHasLimits(int count) {
        assertThat(limitRepository.count()).isEqualTo(count);
    }

    @And("the database has {int} transactions")
    public void theDatabaseHasTransactions(int count) {
        assertThat(transactionRepository.count()).isEqualTo(count);
    }
}
