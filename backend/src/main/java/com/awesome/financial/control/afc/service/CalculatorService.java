package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.CompoundInterestRequest;
import com.awesome.financial.control.afc.dto.CompoundInterestResponse;
import com.awesome.financial.control.afc.dto.FireCalculationRequest;
import com.awesome.financial.control.afc.dto.FireCalculationResponse;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class CalculatorService {

    private static final int MAX_YEARS = 100;
    private static final int MONTHS_IN_YEAR = 12;

    public FireCalculationResponse calculateFire(FireCalculationRequest request) {
        BigDecimal annualReturn = request.annualReturnRate();
        if (request.adjustForInflation()) {
            annualReturn = annualReturn.subtract(BigDecimal.valueOf(0.03));
            if (annualReturn.compareTo(BigDecimal.ZERO) < 0) annualReturn = BigDecimal.ZERO;
        }

        double monthlyRate = Math.pow(1.0 + annualReturn.doubleValue(), 1.0 / 12.0) - 1.0;
        BigDecimal fireNumber =
                request.monthlyExpenses()
                        .multiply(BigDecimal.valueOf(12))
                        .divide(request.safeWithdrawalRate(), 2, RoundingMode.HALF_UP);

        BigDecimal portfolioValue = request.currentPortfolio();
        BigDecimal monthlySavings = request.monthlySavings();

        int totalMonths = 0;
        List<FireCalculationResponse.FireTimelineEntry> timeline = new ArrayList<>();
        timeline.add(new FireCalculationResponse.FireTimelineEntry(0.0, portfolioValue));

        while (portfolioValue.compareTo(fireNumber) < 0
                && totalMonths < MAX_YEARS * MONTHS_IN_YEAR) {
            totalMonths++;
            portfolioValue =
                    portfolioValue
                            .multiply(BigDecimal.valueOf(1.0 + monthlyRate))
                            .add(monthlySavings);

            if (totalMonths % 6 == 0) {
                timeline.add(
                        new FireCalculationResponse.FireTimelineEntry(
                                totalMonths / 12.0,
                                portfolioValue.setScale(2, RoundingMode.HALF_UP)));
            }
        }

        LocalDate retirementDate = LocalDate.now().plusMonths(totalMonths);

        return new FireCalculationResponse(
                fireNumber.setScale(2, RoundingMode.HALF_UP),
                totalMonths,
                retirementDate,
                timeline);
    }

    public CompoundInterestResponse calculateCompoundInterest(CompoundInterestRequest request) {
        double monthlyRate =
                Math.pow(1.0 + request.annualInterestRate().doubleValue(), 1.0 / 12.0) - 1.0;
        int totalMonths = request.years() * 12;

        BigDecimal initial = request.initialAmount();
        BigDecimal contribution = request.monthlyContribution();
        BigDecimal currentAccumulated = initial;
        BigDecimal currentInvested = initial;

        List<CompoundInterestResponse.TimelineEntry> timeline = new ArrayList<>();
        timeline.add(
                new CompoundInterestResponse.TimelineEntry(0, currentInvested, currentAccumulated));

        for (int m = 1; m <= totalMonths; m++) {
            currentAccumulated =
                    currentAccumulated
                            .multiply(BigDecimal.valueOf(1.0 + monthlyRate))
                            .add(contribution);
            currentInvested = currentInvested.add(contribution);

            if (m % 12 == 0 || m == totalMonths) {
                timeline.add(
                        new CompoundInterestResponse.TimelineEntry(
                                m / 12.0,
                                currentInvested.setScale(2, RoundingMode.HALF_UP),
                                currentAccumulated.setScale(2, RoundingMode.HALF_UP)));
            }
        }

        return new CompoundInterestResponse(
                currentAccumulated.setScale(2, RoundingMode.HALF_UP),
                currentInvested.setScale(2, RoundingMode.HALF_UP),
                currentAccumulated.subtract(currentInvested).setScale(2, RoundingMode.HALF_UP),
                timeline);
    }

    public com.awesome.financial.control.afc.dto.InvestmentGoalResponse calculateInvestmentGoal(
            com.awesome.financial.control.afc.dto.InvestmentGoalRequest request) {
        LocalDate now = LocalDate.now();
        long totalMonths =
                java.time.temporal.ChronoUnit.MONTHS.between(
                        now.withDayOfMonth(1), request.targetDate().withDayOfMonth(1));

        if (totalMonths <= 0) totalMonths = 1;

        double monthlyRate =
                Math.pow(1.0 + request.annualReturnRate().doubleValue(), 1.0 / 12.0) - 1.0;
        BigDecimal fv = request.targetAmount();
        BigDecimal pv = request.initialAmount();

        BigDecimal pmt;
        if (monthlyRate == 0) {
            pmt = fv.subtract(pv).divide(BigDecimal.valueOf(totalMonths), 2, RoundingMode.HALF_UP);
        } else {
            double ratePowN = Math.pow(1.0 + monthlyRate, totalMonths);
            double numerator = (fv.doubleValue() - pv.doubleValue() * ratePowN) * monthlyRate;
            double denominator = ratePowN - 1.0;
            pmt = BigDecimal.valueOf(numerator / denominator).setScale(2, RoundingMode.HALF_UP);
        }

        if (pmt.compareTo(BigDecimal.ZERO) < 0) pmt = BigDecimal.ZERO;

        BigDecimal currentAccumulated = pv;
        BigDecimal currentInvested = pv;
        List<com.awesome.financial.control.afc.dto.InvestmentGoalResponse.TimelineEntry> timeline =
                new ArrayList<>();
        timeline.add(
                new com.awesome.financial.control.afc.dto.InvestmentGoalResponse.TimelineEntry(
                        0, currentInvested, currentAccumulated));

        for (int m = 1; m <= totalMonths; m++) {
            currentAccumulated =
                    currentAccumulated.multiply(BigDecimal.valueOf(1.0 + monthlyRate)).add(pmt);
            currentInvested = currentInvested.add(pmt);

            if (m % 12 == 0 || m == totalMonths) {
                timeline.add(
                        new com.awesome.financial.control.afc.dto.InvestmentGoalResponse
                                .TimelineEntry(
                                m / 12.0,
                                currentInvested.setScale(2, RoundingMode.HALF_UP),
                                currentAccumulated.setScale(2, RoundingMode.HALF_UP)));
            }
        }

        return new com.awesome.financial.control.afc.dto.InvestmentGoalResponse(
                pmt,
                currentInvested.setScale(2, RoundingMode.HALF_UP),
                currentAccumulated.subtract(currentInvested).setScale(2, RoundingMode.HALF_UP),
                timeline);
    }
}
