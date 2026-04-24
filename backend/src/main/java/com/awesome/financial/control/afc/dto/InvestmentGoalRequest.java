package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record InvestmentGoalRequest(
        BigDecimal targetAmount,
        LocalDate targetDate,
        BigDecimal annualReturnRate,
        BigDecimal initialAmount) {}
