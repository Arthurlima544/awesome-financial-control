package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.BillRequest;
import com.awesome.financial.control.afc.dto.BillResponse;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;

@RequiredArgsConstructor
public class BillSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;

    @When("I create a bill with name {string}, amount {double} and due day {int}")
    public void createBill(String name, double amount, int dueDay) {
        BillRequest request =
                BillRequest.builder()
                        .name(name)
                        .amount(BigDecimal.valueOf(amount))
                        .dueDay(dueDay)
                        .build();
        context.response = restTemplate.postForEntity("/api/v1/bills", request, BillResponse.class);
    }

    @Then("the bill list should contain {string} with amount {double} and due day {int}")
    public void checkBillList(String name, double amount, int dueDay) {
        List<BillResponse> bills =
                Arrays.asList(restTemplate.getForObject("/api/v1/bills", BillResponse[].class));
        assertThat(bills)
                .anyMatch(
                        b ->
                                b.name().equals(name)
                                        && b.amount().compareTo(BigDecimal.valueOf(amount)) == 0
                                        && b.dueDay() == dueDay);
    }

    @Given("a bill {string} with amount {double} and due day {int} exists")
    public void billExists(String name, double amount, int dueDay) {
        createBill(name, amount, dueDay);
        context.lastBillId = ((BillResponse) context.response.getBody()).id();
    }

    @When("I update the bill {string} to amount {double} and due day {int}")
    public void updateBill(String name, double amount, int dueDay) {
        BillRequest request =
                BillRequest.builder()
                        .name(name)
                        .amount(BigDecimal.valueOf(amount))
                        .dueDay(dueDay)
                        .build();
        context.response =
                restTemplate.exchange(
                        "/api/v1/bills/" + context.lastBillId,
                        HttpMethod.PUT,
                        new HttpEntity<>(request),
                        BillResponse.class);
    }

    @When("I delete the bill {string}")
    public void deleteBill(String name) {
        restTemplate.delete("/api/v1/bills/" + context.lastBillId);
    }

    @Then("the bill list should not contain {string}")
    public void checkBillNotExists(String name) {
        List<BillResponse> bills =
                Arrays.asList(restTemplate.getForObject("/api/v1/bills", BillResponse[].class));
        assertThat(bills).noneMatch(b -> b.name().equals(name));
    }
}
