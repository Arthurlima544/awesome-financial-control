package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.PassiveIncomeDashboardResponse;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class PassiveIncomeMapper {

    public PassiveIncomeDashboardResponse toDashboardResponse(
            BigDecimal passiveIncome,
            BigDecimal expenses,
            double freedomIndex,
            Map<String, BigDecimal> incomeByInvestment,
            List<PassiveIncomeDashboardResponse.MonthlyPassiveIncome> monthlyProgression) {
        return PassiveIncomeDashboardResponse.builder()
                .totalPassiveIncomeCurrentMonth(passiveIncome.setScale(2, RoundingMode.HALF_UP))
                .totalExpensesCurrentMonth(expenses.setScale(2, RoundingMode.HALF_UP))
                .freedomIndex(Math.min(freedomIndex, 100.0))
                .incomeByInvestment(incomeByInvestment)
                .monthlyProgression(monthlyProgression)
                .build();
    }
}
