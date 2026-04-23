package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.InvestmentType;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class InvestmentSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final InvestmentRepository investmentRepository;

    @After
    public void cleanUp() {
        investmentRepository.deleteAll();
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
                        Void.class);
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
}
