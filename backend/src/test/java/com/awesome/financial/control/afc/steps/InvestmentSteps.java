package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.InvestmentDashboardResponse;
import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.InvestmentType;
import com.awesome.financial.control.afc.model.RecurrenceFrequency;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.datatable.DataTable;
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
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class InvestmentSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final InvestmentRepository investmentRepository;
    private final TransactionRepository transactionRepository;
    private final RecurringTransactionRepository recurringTransactionRepository;

    @After
    public void cleanUp() {
        recurringTransactionRepository.deleteAll();
        transactionRepository.deleteAll();
        investmentRepository.deleteAll();
    }

    @Given("a transaction linked to the last created investment")
    public void aTransactionLinkedToLastCreatedInvestment() {
        Transaction transaction = new Transaction();
        transaction.setDescription("Dividendos");
        transaction.setAmount(BigDecimal.valueOf(100));
        transaction.setType(TransactionType.INCOME);
        transaction.setInvestmentId(context.lastInvestmentId);
        transaction.setOccurredAt(Instant.now());
        transactionRepository.save(transaction);
    }

    @Given("I have the following investments:")
    public void iHaveTheFollowingInvestments(DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        for (Map<String, String> row : rows) {
            Investment investment = new Investment();
            investment.setName(row.get("name"));
            investment.setTicker(row.get("ticker"));
            investment.setType(InvestmentType.valueOf(row.get("type")));
            investment.setQuantity(new BigDecimal(row.get("quantity")));
            investment.setAvgCost(new BigDecimal(row.get("avgCost")));
            investment.setCurrentPrice(new BigDecimal(row.get("currentPrice")));
            investmentRepository.save(investment);
        }
    }

    @When("I get the investment dashboard")
    public void iGetTheInvestmentDashboard() {
        context.response =
                restTemplate.getForEntity(
                        "/api/v1/investments/dashboard", InvestmentDashboardResponse.class);
    }

    @Then("the dashboard total invested should be {double}")
    public void theTotalInvestedShouldBe(double expected) {
        InvestmentDashboardResponse body = (InvestmentDashboardResponse) context.response.getBody();
        assertThat(body.totalInvested()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the current total value should be {double}")
    public void theCurrentTotalValueShouldBe(double expected) {
        InvestmentDashboardResponse body = (InvestmentDashboardResponse) context.response.getBody();
        assertThat(body.currentTotalValue()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the total profit should be {double}")
    public void theTotalProfitShouldBe(double expected) {
        InvestmentDashboardResponse body = (InvestmentDashboardResponse) context.response.getBody();
        assertThat(body.totalProfitLoss()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the allocation for {string} should be {double}")
    public void theAllocationForShouldBe(String type, double expected) {
        InvestmentDashboardResponse body = (InvestmentDashboardResponse) context.response.getBody();
        BigDecimal allocation = body.allocationByType().get(InvestmentType.valueOf(type));
        assertThat(allocation).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the performance list should have {int} assets")
    public void thePerformanceListShouldHaveAssets(int count) {
        InvestmentDashboardResponse body = (InvestmentDashboardResponse) context.response.getBody();
        assertThat(body.assetPerformance()).hasSize(count);
    }

    @When(
            "I create an investment with name {string}, ticker {string}, type {string}, quantity {double}, and avg cost {double}")
    public void iCreateAnInvestment(
            String name, String ticker, String type, double quantity, double avgCost) {
        InvestmentRequest request =
                InvestmentRequest.builder()
                        .name(name)
                        .ticker(ticker)
                        .type(InvestmentType.valueOf(type))
                        .quantity(BigDecimal.valueOf(quantity))
                        .avgCost(BigDecimal.valueOf(avgCost))
                        .currentPrice(BigDecimal.valueOf(avgCost)) // initial price same as avg cost
                        .build();
        ResponseEntity<InvestmentResponse> response =
                restTemplate.postForEntity(
                        "/api/v1/investments", request, InvestmentResponse.class);
        context.response = response;
        if (response.getBody() != null) {
            context.lastInvestmentId = response.getBody().id();
        }
    }

    @And("the response should contain investment name {string} and total cost {double}")
    public void theResponseShouldContainInvestmentNameAndTotalCost(String name, double totalCost) {
        InvestmentResponse body = (InvestmentResponse) context.response.getBody();
        assertThat(body.name()).isEqualTo(name);
        assertThat(body.totalCost()).isEqualByComparingTo(BigDecimal.valueOf(totalCost));
    }

    @Given(
            "I have an investment with name {string}, ticker {string}, type {string}, quantity {double}, and avg cost {double}")
    public void iHaveAnInvestment(
            String name, String ticker, String type, double quantity, double avgCost) {
        Investment investment = new Investment();
        investment.setName(name);
        investment.setTicker(ticker);
        investment.setType(InvestmentType.valueOf(type));
        investment.setQuantity(BigDecimal.valueOf(quantity));
        investment.setAvgCost(BigDecimal.valueOf(avgCost));
        investment.setCurrentPrice(BigDecimal.valueOf(avgCost));
        context.lastInvestmentId = investmentRepository.save(investment).getId();
    }

    @When("I update the price of {string} to {double}")
    public void iUpdateThePriceOfTo(String name, double price) {
        ResponseEntity<InvestmentResponse> response =
                restTemplate.exchange(
                        "/api/v1/investments/" + context.lastInvestmentId + "/price?price=" + price,
                        HttpMethod.PATCH,
                        null,
                        InvestmentResponse.class);
        context.response = response;
    }

    @And("the investment {string} current value should be {double}")
    public void theInvestmentCurrentValueShouldBe(String name, double expected) {
        InvestmentResponse body = (InvestmentResponse) context.response.getBody();
        assertThat(body.currentValue()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the investment {string} gain loss should be {double}")
    public void theInvestmentGainLossShouldBe(String name, double expected) {
        InvestmentResponse body = (InvestmentResponse) context.response.getBody();
        assertThat(body.gainLoss()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the investment {string} gain loss percentage should be {double}%")
    public void theInvestmentGainLossPercentageShouldBe(String name, double expected) {
        InvestmentResponse body = (InvestmentResponse) context.response.getBody();
        assertThat(body.gainLossPercentage()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @When("I delete investment with id {string}")
    public void iDeleteInvestmentWithId(String id) {
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + id, HttpMethod.DELETE, null, String.class);
    }

    @Given("I have an investment {string} price {double} quantity {int}")
    public void iHaveAnInvestmentPriceQuantity(String ticker, double price, int quantity) {
        Investment investment = new Investment();
        investment.setName(ticker);
        investment.setTicker(ticker);
        investment.setType(InvestmentType.STOCK);
        investment.setQuantity(BigDecimal.valueOf(quantity));
        investment.setAvgCost(BigDecimal.valueOf(price));
        investment.setCurrentPrice(BigDecimal.valueOf(price));
        context.lastInvestmentId = investmentRepository.save(investment).getId();
    }

    @When("I update {string} price to {double}")
    public void iUpdatePriceTo(String ticker, double price) {
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + context.lastInvestmentId + "/price?price=" + price,
                        HttpMethod.PATCH,
                        null,
                        InvestmentResponse.class);
    }

    @When("I delete investment {string}")
    public void iDeleteInvestment(String ticker) {
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + context.lastInvestmentId,
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @And("the investment {string} should not exist")
    public void theInvestmentShouldNotExist(String ticker) {
        assertThat(investmentRepository.existsById(context.lastInvestmentId)).isFalse();
    }

    @When("I update investment with id {string} price to {double}")
    public void iUpdateInvestmentPriceWithId(String id, double price) {
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + id + "/price?price=" + price,
                        HttpMethod.PATCH,
                        null,
                        String.class);
    }

    @When("I request all investments")
    public void iRequestAllInvestments() {
        context.response = restTemplate.getForEntity("/api/v1/investments", String.class);
    }

    @And("the investments list has {int} items")
    public void theInvestmentsListHasItems(int count) {
        String body = (String) context.response.getBody();
        long bracketCount = body.chars().filter(c -> c == '{').count();
        assertThat(bracketCount).isEqualTo(count);
    }

    @When(
            "I update the last created investment with name {string}, ticker {string}, type {string}, quantity {double}, and avg cost {double}")
    public void iUpdateTheLastCreatedInvestment(
            String name, String ticker, String type, double quantity, double avgCost) {
        InvestmentRequest request =
                InvestmentRequest.builder()
                        .name(name)
                        .ticker(ticker)
                        .type(InvestmentType.valueOf(type))
                        .quantity(BigDecimal.valueOf(quantity))
                        .avgCost(BigDecimal.valueOf(avgCost))
                        .currentPrice(BigDecimal.valueOf(avgCost))
                        .build();
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + context.lastInvestmentId,
                        HttpMethod.PUT,
                        new HttpEntity<>(request),
                        InvestmentResponse.class);
    }

    @When(
            "I update investment with id {string} with name {string}, ticker {string}, type {string}, quantity {double}, and avg cost {double}")
    public void iUpdateInvestmentWithId(
            String id, String name, String ticker, String type, double quantity, double avgCost) {
        InvestmentRequest request =
                InvestmentRequest.builder()
                        .name(name)
                        .ticker(ticker)
                        .type(InvestmentType.valueOf(type))
                        .quantity(BigDecimal.valueOf(quantity))
                        .avgCost(BigDecimal.valueOf(avgCost))
                        .currentPrice(BigDecimal.valueOf(avgCost))
                        .build();
        context.response =
                restTemplate.exchange(
                        "/api/v1/investments/" + id,
                        HttpMethod.PUT,
                        new HttpEntity<>(request),
                        String.class);
    }

    @Given("a recurring transaction linked to the last created investment")
    public void aRecurringTransactionLinkedToLastCreatedInvestment() {
        RecurringTransaction rt = new RecurringTransaction();
        rt.setDescription("Dividendos recorrentes");
        rt.setAmount(BigDecimal.valueOf(50));
        rt.setType(TransactionType.INCOME);
        rt.setFrequency(RecurrenceFrequency.MONTHLY);
        rt.setNextDueAt(Instant.now().plus(30, ChronoUnit.DAYS));
        rt.setInvestmentId(context.lastInvestmentId);
        recurringTransactionRepository.save(rt);
    }
}
