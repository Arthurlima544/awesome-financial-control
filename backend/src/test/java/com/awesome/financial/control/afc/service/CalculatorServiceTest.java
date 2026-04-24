package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.InvestmentGoalRequest;
import com.awesome.financial.control.afc.dto.InvestmentGoalResponse;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class CalculatorServiceTest {

    private final InflationService inflationService = new InflationService();
    private final CalculatorService calculatorService = new CalculatorService(inflationService);

    @Test
    void shouldCalculateInvestmentGoalWithZeroInterest() {
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(100000),
                        LocalDate.now().plusMonths(100),
                        BigDecimal.ZERO,
                        BigDecimal.ZERO,
                        false);

        InvestmentGoalResponse response = calculatorService.calculateInvestmentGoal(request);

        assertThat(response.requiredMonthlyContribution()).isEqualByComparingTo("1000.00");
        assertThat(response.totalContributed()).isEqualByComparingTo("100000.00");
        assertThat(response.totalInterestEarned()).isEqualByComparingTo("0.00");
    }

    @Test
    void shouldCalculateInvestmentGoalWithInterest() {
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(1000000),
                        LocalDate.now().plusYears(10),
                        BigDecimal.valueOf(0.10),
                        BigDecimal.ZERO,
                        false);

        InvestmentGoalResponse response = calculatorService.calculateInvestmentGoal(request);

        assertThat(response.requiredMonthlyContribution()).isGreaterThan(BigDecimal.valueOf(5000));
        assertThat(response.requiredMonthlyContribution()).isLessThan(BigDecimal.valueOf(6000));
        assertThat(response.totalInterestEarned()).isGreaterThan(BigDecimal.valueOf(300000));
    }

    @Test
    void shouldHandleInitialAmountHigherThanTarget() {
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(10000),
                        LocalDate.now().plusYears(1),
                        BigDecimal.valueOf(0.10),
                        BigDecimal.valueOf(20000),
                        false);

        InvestmentGoalResponse response = calculatorService.calculateInvestmentGoal(request);

        assertThat(response.requiredMonthlyContribution()).isEqualByComparingTo("0.00");
    }

    @Test
    void shouldCalculateInflationAdjustedGoal() {
        // Without inflation adjustment
        InvestmentGoalRequest nominalRequest =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(1000000),
                        LocalDate.now().plusYears(10),
                        BigDecimal.valueOf(0.10),
                        BigDecimal.ZERO,
                        false);
        InvestmentGoalResponse nominalResponse =
                calculatorService.calculateInvestmentGoal(nominalRequest);

        // With inflation adjustment
        InvestmentGoalRequest realRequest =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(1000000),
                        LocalDate.now().plusYears(10),
                        BigDecimal.valueOf(0.10),
                        BigDecimal.ZERO,
                        true);
        InvestmentGoalResponse realResponse =
                calculatorService.calculateInvestmentGoal(realRequest);

        // Required contribution should be HIGHER because real return is LOWER (10% nominal - 4.5%
        // inflation approx)
        assertThat(realResponse.requiredMonthlyContribution())
                .isGreaterThan(nominalResponse.requiredMonthlyContribution());
    }
}
