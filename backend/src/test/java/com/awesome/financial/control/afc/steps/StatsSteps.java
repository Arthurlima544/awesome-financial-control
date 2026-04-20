package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.YearMonth;
import java.time.ZoneOffset;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;

public class StatsSteps {

    @Autowired private TestRestTemplate restTemplate;

    @Autowired private TransactionRepository transactionRepository;

    @Autowired private ScenarioContext ctx;

    @Given(
            "a transaction with description {string} amount {bigdecimal} type {word} occurred in the previous month")
    public void aTransactionOccurredInThePreviousMonth(
            String description, BigDecimal amount, String type) {
        YearMonth lastMonth = YearMonth.now(ZoneOffset.UTC).minusMonths(1);
        Transaction transaction = new Transaction();
        transaction.setDescription(description);
        transaction.setAmount(amount);
        transaction.setType(TransactionType.valueOf(type));
        transaction.setOccurredAt(lastMonth.atDay(15).atStartOfDay().toInstant(ZoneOffset.UTC));
        transactionRepository.save(transaction);
    }

    @When("I request the monthly stats")
    public void iRequestTheMonthlyStats() {
        ctx.response = restTemplate.getForEntity("/api/v1/stats/monthly", String.class);
    }

    @And("the stats response contains 6 months")
    public void theStatsResponseContains6Months() {
        long count = ctx.response.getBody().chars().filter(c -> c == '{').count();
        assertThat(count).isEqualTo(6);
    }

    @And("the current month income is {bigdecimal}")
    public void theCurrentMonthIncomeIs(BigDecimal expected) {
        assertThat(monthJson(YearMonth.now(ZoneOffset.UTC)))
                .contains("\"income\":" + expected.stripTrailingZeros().toPlainString());
    }

    @And("the current month expenses is {bigdecimal}")
    public void theCurrentMonthExpensesIs(BigDecimal expected) {
        assertThat(monthJson(YearMonth.now(ZoneOffset.UTC)))
                .contains("\"expenses\":" + expected.stripTrailingZeros().toPlainString());
    }

    @And("the prior month income is {bigdecimal}")
    public void thePriorMonthIncomeIs(BigDecimal expected) {
        assertThat(monthJson(YearMonth.now(ZoneOffset.UTC).minusMonths(1)))
                .contains("\"income\":" + expected.stripTrailingZeros().toPlainString());
    }

    private String monthJson(YearMonth month) {
        String body = ctx.response.getBody();
        String monthKey = "\"month\":\"" + month + "\"";
        int keyIdx = body.indexOf(monthKey);
        assertThat(keyIdx)
                .as("month entry for %s not found in response", month)
                .isGreaterThanOrEqualTo(0);
        int openBrace = body.lastIndexOf('{', keyIdx);
        int closeBrace = body.indexOf('}', keyIdx);
        return body.substring(openBrace, closeBrace + 1);
    }
}
