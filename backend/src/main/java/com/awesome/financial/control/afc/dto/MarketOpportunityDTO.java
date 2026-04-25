package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;

public record MarketOpportunityDTO(
        String ticker,
        String name,
        BigDecimal price,
        BigDecimal changePercent,
        BigDecimal dividendYield,
        boolean isFii,
        BigDecimal priceEarnings,
        String sector,
        BigDecimal dyVsCdi,
        String logoUrl,
        java.time.ZonedDateTime lastUpdated) {}
