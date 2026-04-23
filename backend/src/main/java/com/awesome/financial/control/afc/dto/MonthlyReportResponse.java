package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;

@Builder
public record MonthlyReportResponse(
        BigDecimal totalIncome,
        BigDecimal totalExpenses,
        BigDecimal savingsRate,
        List<CategoryBreakdown> categories,
        List<CategoryComparison> comparison) {

    @Builder
    public record CategoryBreakdown(String category, BigDecimal amount, double percentage) {}

    @Builder
    public record CategoryComparison(
            String category, BigDecimal currentAmount, BigDecimal previousAmount) {}
}
