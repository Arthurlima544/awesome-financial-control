package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;

public record InvestmentGoalRequest(
        @NotNull @DecimalMin("0.01") BigDecimal targetAmount,
        @NotNull LocalDate targetDate,
        @NotNull @DecimalMin("0.00") BigDecimal annualReturnRate,
        @NotNull @DecimalMin("0.00") BigDecimal initialAmount,
        boolean adjustForInflation) {}
