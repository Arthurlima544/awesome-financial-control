package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.PassiveIncomeDashboardResponse;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;

@RequiredArgsConstructor
public class PassiveIncomeSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final TransactionRepository transactionRepository;
    private final InvestmentRepository investmentRepository;

    @Given("I have the following transactions:")
    public void iHaveTheFollowingTransactions(DataTable dataTable) {
        List<Map<String, String>> rows = dataTable.asMaps(String.class, String.class);
        for (Map<String, String> row : rows) {
            Transaction t = new Transaction();
            t.setDescription(row.get("description"));
            t.setAmount(new BigDecimal(row.get("amount")));
            t.setType(TransactionType.valueOf(row.get("type")));
            t.setCategory(row.get("category"));
            t.setOccurredAt(Instant.parse(row.get("occurredAt") + "T00:00:00Z"));
            t.setPassive(Boolean.parseBoolean(row.get("isPassive")));

            String ticker = row.get("ticker");
            if (ticker != null && !ticker.isBlank()) {
                t.setInvestmentId(investmentRepository.findByTicker(ticker).get().getId());
            }

            transactionRepository.save(t);
        }
    }

    @When("I get the passive income dashboard")
    public void iGetThePassiveIncomeDashboard() {
        context.response =
                restTemplate.getForEntity(
                        "/api/v1/passive-income/dashboard", PassiveIncomeDashboardResponse.class);
    }

    @Then("the total passive income should be {double}")
    public void theTotalPassiveIncomeShouldBe(double expected) {
        PassiveIncomeDashboardResponse body =
                (PassiveIncomeDashboardResponse) context.response.getBody();
        assertThat(body.totalPassiveIncomeCurrentMonth())
                .isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the total expenses should be {double}")
    public void theTotalExpensesShouldBe(double expected) {
        PassiveIncomeDashboardResponse body =
                (PassiveIncomeDashboardResponse) context.response.getBody();
        assertThat(body.totalExpensesCurrentMonth())
                .isEqualByComparingTo(BigDecimal.valueOf(expected));
    }

    @And("the freedom index should be {double}")
    public void theFreedomIndexShouldBe(double expected) {
        PassiveIncomeDashboardResponse body =
                (PassiveIncomeDashboardResponse) context.response.getBody();
        assertThat(body.freedomIndex()).isEqualTo(expected);
    }

    @And("the income from {string} should be {double}")
    public void theIncomeFromShouldBe(String ticker, double expected) {
        PassiveIncomeDashboardResponse body =
                (PassiveIncomeDashboardResponse) context.response.getBody();
        assertThat(body.incomeByInvestment().get(ticker))
                .isEqualByComparingTo(BigDecimal.valueOf(expected));
    }
}
