package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;

public record InvestmentGoalResponse(
        BigDecimal requiredMonthlyContribution,
        BigDecimal totalContributed,
        BigDecimal totalInterestEarned,
        List<TimelineEntry> timeline) {
    public record TimelineEntry(double years, BigDecimal invested, BigDecimal accumulated) {}
}
