package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.InvestmentType;
import java.math.BigDecimal;
import java.util.UUID;

public record InvestmentResponse(
        UUID id,
        String name,
        String ticker,
        InvestmentType type,
        BigDecimal quantity,
        BigDecimal avgCost,
        BigDecimal currentPrice,
        BigDecimal totalCost,
        BigDecimal currentValue,
        BigDecimal gainLoss,
        BigDecimal gainLossPercentage) {}
