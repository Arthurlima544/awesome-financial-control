package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpMethod;

public class TransactionSteps {

    @Autowired private TestRestTemplate restTemplate;

    @Autowired private TransactionRepository transactionRepository;

    @Autowired private ScenarioContext ctx;

    @After
    public void cleanUp() {
        transactionRepository.deleteAll();
    }

    @Given("a transaction with description {string} amount {bigdecimal} type {word} occurred today")
    public void aTransactionOccurredToday(String description, BigDecimal amount, String type) {
        Transaction transaction = new Transaction();
        transaction.setDescription(description);
        transaction.setAmount(amount);
        transaction.setType(TransactionType.valueOf(type));
        transaction.setOccurredAt(Instant.now());
        ctx.lastTransactionId = transactionRepository.save(transaction).getId();
    }

    @Given(
            "a transaction with description {string} amount {bigdecimal} type {word} occurred {int} days ago")
    public void aTransactionOccurredDaysAgo(
            String description, BigDecimal amount, String type, int days) {
        Transaction transaction = new Transaction();
        transaction.setDescription(description);
        transaction.setAmount(amount);
        transaction.setType(TransactionType.valueOf(type));
        transaction.setOccurredAt(Instant.now().minus(days, ChronoUnit.DAYS));
        ctx.lastTransactionId = transactionRepository.save(transaction).getId();
    }

    @When("I request the financial summary")
    public void iRequestTheSummary() {
        ctx.response = restTemplate.getForEntity("/api/v1/summary", String.class);
    }

    @When("I request the last {int} transactions")
    public void iRequestLastTransactions(int limit) {
        ctx.response =
                restTemplate.getForEntity("/api/v1/transactions?limit=" + limit, String.class);
    }

    @Then("the response status is {int}")
    public void theResponseStatusIs(int status) {
        assertThat(ctx.response.getStatusCode().value()).isEqualTo(status);
    }

    @And("the total income is {bigdecimal}")
    public void theTotalIncomeIs(BigDecimal expected) {
        assertThat(ctx.response.getBody())
                .contains("\"totalIncome\":" + expected.stripTrailingZeros().toPlainString());
    }

    @And("the total expenses is {bigdecimal}")
    public void theTotalExpensesIs(BigDecimal expected) {
        assertThat(ctx.response.getBody())
                .contains("\"totalExpenses\":" + expected.stripTrailingZeros().toPlainString());
    }

    @And("the balance is {bigdecimal}")
    public void theBalanceIs(BigDecimal expected) {
        assertThat(ctx.response.getBody())
                .contains("\"balance\":" + expected.stripTrailingZeros().toPlainString());
    }

    @And("the transaction list is empty")
    public void theTransactionListIsEmpty() {
        assertThat(ctx.response.getBody()).isEqualTo("[]");
    }

    @And("the transaction list has {int} items")
    public void theTransactionListHasItems(int count) {
        long commaCount = ctx.response.getBody().chars().filter(c -> c == '{').count();
        assertThat(commaCount).isEqualTo(count);
    }

    @And("the first transaction description is {string}")
    public void theFirstTransactionDescriptionIs(String description) {
        assertThat(ctx.response.getBody()).contains("\"description\":\"" + description + "\"");
    }

    @When("I request all transactions")
    public void iRequestAllTransactions() {
        ctx.response = restTemplate.getForEntity("/api/v1/transactions", String.class);
    }

    @When("I delete the last created transaction")
    public void iDeleteTheLastCreatedTransaction() {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/transactions/" + ctx.lastTransactionId,
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I delete transaction with id {string}")
    public void iDeleteTransactionWithId(String id) {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/transactions/" + UUID.fromString(id),
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @And("the transaction no longer exists")
    public void theTransactionNoLongerExists() {
        assertThat(transactionRepository.existsById(ctx.lastTransactionId)).isFalse();
    }
}
