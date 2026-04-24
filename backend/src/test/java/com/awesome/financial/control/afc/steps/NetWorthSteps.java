package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.NetWorthPoint;
import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.InvestmentType;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class NetWorthSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final TransactionRepository transactionRepository;
    private final InvestmentRepository investmentRepository;
    private final CategoryRepository categoryRepository;

    @Given("the database is empty")
    public void theDatabaseIsEmpty() {
        transactionRepository.deleteAll();
        investmentRepository.deleteAll();
        categoryRepository.deleteAll();
    }

    @Given("a category {string} exists")
    public void aCategoryExists(String name) {
        Category c = new Category();
        c.setName(name);
        categoryRepository.save(c);
    }

    @Given("a transaction {string} of {double} type {string} occurred at {string}")
    public void aTransactionOfTypeOccurredAt(
            String desc, double amount, String type, String occurredAt) {
        Transaction t = new Transaction();
        t.setDescription(desc);
        t.setAmount(BigDecimal.valueOf(amount));
        t.setType(TransactionType.valueOf(type));
        t.setOccurredAt(Instant.parse(occurredAt));
        transactionRepository.save(t);
    }

    @Given(
            "an investment {string} ticker {string} type {string} quantity {string} avgCost {string} price {string} created at {string}")
    public void anInvestmentTickerTypeQuantityAvgCostPriceCreatedAt(
            String name,
            String ticker,
            String type,
            String quantity,
            String avgCost,
            String price,
            String createdAt) {
        Investment i = new Investment();
        i.setName(name);
        i.setTicker(ticker);
        i.setType(InvestmentType.valueOf(type));
        i.setQuantity(new BigDecimal(quantity));
        i.setAvgCost(new BigDecimal(avgCost));
        i.setCurrentPrice(new BigDecimal(price));
        i.setCreatedAt(Instant.parse(createdAt));
        investmentRepository.save(i);
    }

    @When("I request the net worth evolution")
    public void iRequestTheNetWorthEvolution() {
        ResponseEntity<List<NetWorthPoint>> response =
                restTemplate.exchange(
                        "/api/v1/stats/net-worth",
                        HttpMethod.GET,
                        null,
                        new ParameterizedTypeReference<List<NetWorthPoint>>() {});
        context.response = response;
    }

    @Then("I should receive {int} data points")
    public void iShouldReceiveDataPoints(int count) {
        List<NetWorthPoint> body = (List<NetWorthPoint>) context.response.getBody();
        assertThat(body).hasSize(count);
    }

    @And("the point for {string} should have assets {double}")
    public void thePointForShouldHaveAssets(String month, double expectedAssets) {
        List<NetWorthPoint> body = (List<NetWorthPoint>) context.response.getBody();
        NetWorthPoint point =
                body.stream()
                        .filter(p -> p.month().equals(month))
                        .findFirst()
                        .orElseThrow(
                                () -> new AssertionError("Point not found for month: " + month));

        assertThat(point.assets()).isEqualByComparingTo(BigDecimal.valueOf(expectedAssets));
    }
}
