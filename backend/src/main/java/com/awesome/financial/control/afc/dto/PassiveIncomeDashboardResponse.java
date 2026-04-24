package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import lombok.Builder;

@Builder
public record PassiveIncomeDashboardResponse(
        BigDecimal totalPassiveIncomeCurrentMonth,
        double freedomIndex,
        BigDecimal totalExpensesCurrentMonth,
        Map<String, BigDecimal> incomeByInvestment,
        List<MonthlyPassiveIncome> monthlyProgression) {
    public record MonthlyPassiveIncome(String month, BigDecimal amount) {}
}
