package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record MonthlyStatsResponse(String month, BigDecimal income, BigDecimal expenses) {}
