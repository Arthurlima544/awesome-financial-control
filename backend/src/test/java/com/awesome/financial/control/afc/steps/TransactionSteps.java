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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;

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
        transactionRepository.save(transaction);
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
        transactionRepository.save(transaction);
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
}
