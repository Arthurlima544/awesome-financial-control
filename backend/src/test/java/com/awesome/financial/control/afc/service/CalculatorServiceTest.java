package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.InvestmentGoalRequest;
import com.awesome.financial.control.afc.dto.InvestmentGoalResponse;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class CalculatorServiceTest {

    private final CalculatorService calculatorService = new CalculatorService();

    @Test
    void shouldCalculateInvestmentGoalWithZeroInterest() {
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(100000),
                        LocalDate.now().plusMonths(100),
                        BigDecimal.ZERO,
                        BigDecimal.ZERO);

        InvestmentGoalResponse response = calculatorService.calculateInvestmentGoal(request);

        assertThat(response.requiredMonthlyContribution()).isEqualByComparingTo("1000.00");
        assertThat(response.totalContributed()).isEqualByComparingTo("100000.00");
        assertThat(response.totalInterestEarned()).isEqualByComparingTo("0.00");
    }

    @Test
    void shouldCalculateInvestmentGoalWithInterest() {
        // Target: 1.000.000 in 10 years (120 months) at 10% annual
        // PV = 0
        // r = (1.10)^(1/12) - 1 approx 0.00797414
        // PMT = 1.000.000 * r / ((1+r)^120 - 1) approx 5.200 - 5.500
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(1000000),
                        LocalDate.now().plusYears(10),
                        BigDecimal.valueOf(0.10),
                        BigDecimal.ZERO);

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
                        BigDecimal.valueOf(20000));

        InvestmentGoalResponse response = calculatorService.calculateInvestmentGoal(request);

        assertThat(response.requiredMonthlyContribution()).isEqualByComparingTo("0.00");
    }
}
