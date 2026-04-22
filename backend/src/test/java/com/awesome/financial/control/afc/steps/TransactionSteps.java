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
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

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

    @When(
            "I update the last created transaction with description {string} amount {bigdecimal} type {word}")
    public void iUpdateTheLastCreatedTransaction(
            String description, BigDecimal amount, String type) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String body =
                String.format(
                        "{\"description\":\"%s\",\"amount\":%s,\"type\":\"%s\",\"occurredAt\":\"%s\"}",
                        description, amount.toPlainString(), type, Instant.now().toString());
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/transactions/" + ctx.lastTransactionId,
                        HttpMethod.PUT,
                        new HttpEntity<>(body, headers),
                        String.class);
    }

    @When(
            "I update transaction with id {string} with description {string} amount {bigdecimal} type {word}")
    public void iUpdateTransactionWithId(
            String id, String description, BigDecimal amount, String type) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String body =
                String.format(
                        "{\"description\":\"%s\",\"amount\":%s,\"type\":\"%s\",\"occurredAt\":\"%s\"}",
                        description, amount.toPlainString(), type, Instant.now().toString());
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/transactions/" + UUID.fromString(id),
                        HttpMethod.PUT,
                        new HttpEntity<>(body, headers),
                        String.class);
    }

    @And("the transaction description is {string}")
    public void theTransactionDescriptionIs(String description) {
        assertThat(ctx.response.getBody()).contains("\"description\":\"" + description + "\"");
    }

    @And("the transaction amount is {bigdecimal}")
    public void theTransactionAmountIs(BigDecimal amount) {
        assertThat(ctx.response.getBody())
                .contains("\"amount\":" + amount.stripTrailingZeros().toPlainString());
    }

    @When("I import the following transactions:")
    public void iImportTheFollowingTransactions(io.cucumber.datatable.DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        String body =
                "["
                        + rows.stream()
                                .map(
                                        row ->
                                                String.format(
                                                        "{\"description\":\"%s\",\"amount\":%s,\"type\":\"%s\",\"category\":\"%s\",\"occurredAt\":\"%s\"}",
                                                        row.get("description"),
                                                        row.get("amount"),
                                                        row.get("type"),
                                                        row.get("category"),
                                                        row.get("occurredAt")))
                                .collect(Collectors.joining(","))
                        + "]";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        ctx.response =
                restTemplate.postForEntity(
                        "/api/v1/transactions/bulk", new HttpEntity<>(body, headers), String.class);
    }

    @And("the transaction list contains description {string} with amount {bigdecimal}")
    public void theTransactionListContainsDescriptionWithAmount(
            String description, BigDecimal amount) {
        assertThat(ctx.response.getBody()).contains("\"description\":\"" + description + "\"");
        assertThat(ctx.response.getBody())
                .contains("\"amount\":" + amount.stripTrailingZeros().toPlainString());
    }

    @When("I import an invalid bulk request")
    public void iImportAnInvalidBulkRequest() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String body = "invalid-json";
        ctx.response =
                restTemplate.postForEntity(
                        "/api/v1/transactions/bulk", new HttpEntity<>(body, headers), String.class);
    }

    @When("I import an empty list of transactions")
    public void iImportAnEmptyList() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String body = "[]";
        ctx.response =
                restTemplate.postForEntity(
                        "/api/v1/transactions/bulk", new HttpEntity<>(body, headers), String.class);
    }
}
