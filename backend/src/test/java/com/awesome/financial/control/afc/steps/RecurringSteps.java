package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.model.RecurrenceFrequency;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

public class RecurringSteps {

    @Autowired private TestRestTemplate restTemplate;
    @Autowired private RecurringTransactionRepository recurringRepository;
    @Autowired private TransactionRepository transactionRepository;
    @Autowired private ScenarioContext ctx;

    @io.cucumber.java.After
    public void cleanUp() {
        recurringRepository.deleteAll();
    }

    @When(
            "I create a {string} recurring transaction {string} with amount {double} in category {string} due in {int} days")
    public void iCreateARecurringTransaction(
            String frequency, String description, double amount, String category, int days) {
        RecurringTransactionRequest request =
                new RecurringTransactionRequest(
                        description,
                        BigDecimal.valueOf(amount),
                        TransactionType.EXPENSE,
                        category,
                        RecurrenceFrequency.valueOf(frequency),
                        Instant.now().plus(days, ChronoUnit.DAYS),
                        true);
        ResponseEntity<String> response =
                restTemplate.postForEntity("/api/v1/recurring", request, String.class);
        ctx.response = response;
    }

    @And("there are {int} recurring rules")
    public void thereAreRecurringRules(int count) {
        assertThat(recurringRepository.count()).isEqualTo(count);
    }

    @Then("the response contains {string}")
    public void theResponseContains(String content) {
        assertThat(ctx.response.getBody()).contains(content);
    }

    @When("I process pending recurring transactions")
    public void iProcessPendingRecurringTransactions() {
        restTemplate.postForEntity("/api/v1/recurring/process", null, Void.class);
    }

    @And("the recurring rule {string} next due date is updated")
    public void theRecurringRuleNextDueDateIsUpdated(String description) {
        com.awesome.financial.control.afc.model.RecurringTransaction rule =
                recurringRepository.findAll().stream()
                        .filter(r -> r.getDescription().equals(description))
                        .findFirst()
                        .orElseThrow();
        // Since it was DAILY and set to yesterday, it should now be today or later
        assertThat(rule.getNextDueAt()).isAfter(Instant.now().minus(1, ChronoUnit.HOURS));
    }

    @And("I pause the recurring rule {string}")
    public void iPauseTheRecurringRule(String description) {
        com.awesome.financial.control.afc.model.RecurringTransaction entity =
                recurringRepository.findAll().stream()
                        .filter(r -> r.getDescription().equals(description))
                        .findFirst()
                        .orElseThrow();

        RecurringTransactionRequest request =
                new RecurringTransactionRequest(
                        entity.getDescription(),
                        entity.getAmount(),
                        entity.getType(),
                        entity.getCategory(),
                        entity.getFrequency(),
                        entity.getNextDueAt(),
                        false);
        restTemplate.put("/api/v1/recurring/" + entity.getId(), request);
    }
}
