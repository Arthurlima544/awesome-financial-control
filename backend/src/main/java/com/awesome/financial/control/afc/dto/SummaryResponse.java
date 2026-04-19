package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record SummaryResponse(
        BigDecimal totalIncome, BigDecimal totalExpenses, BigDecimal balance) {}
