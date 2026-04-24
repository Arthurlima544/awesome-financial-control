package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record FireCalculationRequest(
        @NotNull @DecimalMin("0.01") BigDecimal monthlyExpenses,
        @NotNull @DecimalMin("0.00") BigDecimal currentPortfolio,
        @NotNull @DecimalMin("0.00") BigDecimal monthlySavings,
        @NotNull @DecimalMin("0.01") BigDecimal annualReturnRate,
        @NotNull @DecimalMin("0.01") BigDecimal safeWithdrawalRate,
        boolean adjustForInflation) {}
