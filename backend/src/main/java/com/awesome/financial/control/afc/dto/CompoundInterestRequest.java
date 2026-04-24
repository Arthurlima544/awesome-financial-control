package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record CompoundInterestRequest(
        @NotNull @DecimalMin("0.00") BigDecimal initialAmount,
        @NotNull @DecimalMin("0.00") BigDecimal monthlyContribution,
        @NotNull @Min(1) int years,
        @NotNull @DecimalMin("0.00") BigDecimal annualInterestRate,
        boolean adjustForInflation) {}
