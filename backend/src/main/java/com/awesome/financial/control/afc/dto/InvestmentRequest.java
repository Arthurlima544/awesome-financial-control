package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.InvestmentType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record InvestmentRequest(
        @NotBlank String name,
        String ticker,
        @NotNull InvestmentType type,
        @NotNull @Positive BigDecimal quantity,
        @NotNull @Positive BigDecimal avgCost,
        @NotNull @Positive BigDecimal currentPrice) {}
