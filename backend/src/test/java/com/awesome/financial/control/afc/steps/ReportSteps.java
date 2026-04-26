package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.MonthlyReportResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;

@RequiredArgsConstructor
public class ReportSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final ObjectMapper objectMapper;

    @SneakyThrows
    @When("I request the monthly report for {string}")
    public void iRequestTheMonthlyReportFor(String month) {
        ResponseEntity<String> response =
                restTemplate.getForEntity("/api/v1/reports/monthly?month=" + month, String.class);
        context.response = response;
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            MonthlyReportResponse report =
                    objectMapper.readValue(response.getBody(), MonthlyReportResponse.class);
            context.monthlyReportResponse =
                    ResponseEntity.status(response.getStatusCode()).body(report);
        }
    }

    @Then("the response should contain:")
    public void theResponseShouldContain(Map<String, String> expectedValues) {
        MonthlyReportResponse report = context.monthlyReportResponse.getBody();
        assertThat(report).isNotNull();

        if (expectedValues.containsKey("totalIncome")) {
            assertThat(report.totalIncome())
                    .isEqualByComparingTo(expectedValues.get("totalIncome"));
        }
        if (expectedValues.containsKey("totalExpenses")) {
            assertThat(report.totalExpenses())
                    .isEqualByComparingTo(expectedValues.get("totalExpenses"));
        }
        if (expectedValues.containsKey("savingsRate")) {
            assertThat(report.savingsRate())
                    .isEqualByComparingTo(expectedValues.get("savingsRate"));
        }
    }

    @And("the category {string} should have amount {double}")
    public void theCategoryShouldHaveAmount(String categoryName, double expectedAmount) {
        MonthlyReportResponse report = context.monthlyReportResponse.getBody();
        assertThat(report.categories())
                .anySatisfy(
                        c -> {
                            assertThat(c.category()).isEqualTo(categoryName);
                            assertThat(c.amount())
                                    .isEqualByComparingTo(BigDecimal.valueOf(expectedAmount));
                        });
    }

    @And("the category {string} comparison should show current {double} and previous {double}")
    public void theCategoryComparisonShouldShowCurrentAndPrevious(
            String categoryName, double current, double previous) {
        MonthlyReportResponse report = context.monthlyReportResponse.getBody();
        assertThat(report.comparison())
                .anySatisfy(
                        c -> {
                            assertThat(c.category()).isEqualTo(categoryName);
                            assertThat(c.currentAmount())
                                    .isEqualByComparingTo(BigDecimal.valueOf(current));
                            assertThat(c.previousAmount())
                                    .isEqualByComparingTo(BigDecimal.valueOf(previous));
                        });
    }

    @And("the category comparison for null should show current {double} and previous {double}")
    public void theCategoryComparisonForNullShouldShowCurrentAndPrevious(
            double current, double previous) {
        MonthlyReportResponse report = context.monthlyReportResponse.getBody();
        assertThat(report.comparison())
                .anySatisfy(
                        c -> {
                            assertThat(c.category()).isNull();
                            assertThat(c.currentAmount())
                                    .isEqualByComparingTo(BigDecimal.valueOf(current));
                            assertThat(c.previousAmount())
                                    .isEqualByComparingTo(BigDecimal.valueOf(previous));
                        });
    }
}
