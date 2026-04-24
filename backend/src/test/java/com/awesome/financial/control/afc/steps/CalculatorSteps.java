package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.CompoundInterestRequest;
import com.awesome.financial.control.afc.dto.CompoundInterestResponse;
import com.awesome.financial.control.afc.dto.FireCalculationRequest;
import com.awesome.financial.control.afc.dto.FireCalculationResponse;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class CalculatorSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;

    @When("I calculate FIRE with:")
    public void iCalculateFireWith(Map<String, String> data) {
        FireCalculationRequest request =
                new FireCalculationRequest(
                        new BigDecimal(data.get("monthlyExpenses")),
                        new BigDecimal(data.get("currentPortfolio")),
                        new BigDecimal(data.get("monthlySavings")),
                        new BigDecimal(data.get("annualReturnRate")),
                        new BigDecimal(data.get("safeWithdrawalRate")),
                        Boolean.parseBoolean(data.getOrDefault("adjustForInflation", "false")));
        ResponseEntity<FireCalculationResponse> response =
                restTemplate.postForEntity(
                        "/api/v1/calculators/fire", request, FireCalculationResponse.class);
        context.response = response;
    }

    @And("the FIRE number should be {double}")
    public void theFireNumberShouldBe(double expected) {
        FireCalculationResponse body = (FireCalculationResponse) context.response.getBody();
        assertThat(body.fireNumber()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the months to FIRE should be greater than 0")
    public void theMonthsToFireShouldBeGreaterThan0() {
        FireCalculationResponse body = (FireCalculationResponse) context.response.getBody();
        assertThat(body.monthsToFire()).isGreaterThan(0);
    }

    @And("the yearly timeline should not be empty")
    public void theYearlyTimelineShouldNotBeEmpty() {
        FireCalculationResponse body = (FireCalculationResponse) context.response.getBody();
        assertThat(body.yearlyTimeline()).isNotEmpty();
    }

    @When("I calculate compound interest with:")
    public void iCalculateCompoundInterestWith(Map<String, String> data) {
        CompoundInterestRequest request =
                new CompoundInterestRequest(
                        new BigDecimal(data.get("initialAmount")),
                        new BigDecimal(data.get("monthlyContribution")),
                        Integer.parseInt(data.get("years")),
                        new BigDecimal(data.get("annualInterestRate")));
        ResponseEntity<CompoundInterestResponse> response =
                restTemplate.postForEntity(
                        "/api/v1/calculators/compound-interest",
                        request,
                        CompoundInterestResponse.class);
        context.response = response;
    }

    @Then("the final amount should be approximately {double}")
    public void theFinalAmountShouldBeApproximately(double expected) {
        CompoundInterestResponse body = (CompoundInterestResponse) context.response.getBody();
        assertThat(body.finalAmount())
                .isCloseTo(
                        BigDecimal.valueOf(expected),
                        org.assertj.core.data.Offset.offset(BigDecimal.valueOf(1.0)));
    }

    @And("the total invested should be {double}")
    public void theTotalInvestedShouldBe(double expected) {
        CompoundInterestResponse body = (CompoundInterestResponse) context.response.getBody();
        assertThat(body.totalInvested()).isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the total interest should be approximately {double}")
    public void theTotalInterestShouldBeApproximately(double expected) {
        CompoundInterestResponse body = (CompoundInterestResponse) context.response.getBody();
        assertThat(body.totalInterest())
                .isCloseTo(
                        BigDecimal.valueOf(expected),
                        org.assertj.core.data.Offset.offset(BigDecimal.valueOf(1.0)));
    }

    @And("the compound interest timeline should have {int} entries")
    public void theCompoundInterestTimelineShouldHaveEntries(int expected) {
        CompoundInterestResponse body = (CompoundInterestResponse) context.response.getBody();
        assertThat(body.timeline()).hasSize(expected);
    }
}
