package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;

public record BrapiQuoteResponse(List<BrapiQuoteResult> results, String requestedAt) {
    public record BrapiQuoteResult(
            String symbol,
            String shortName,
            String longName,
            String currency,
            BigDecimal regularMarketPrice,
            BigDecimal regularMarketChange,
            BigDecimal regularMarketChangePercent,
            String logourl,
            BrapiFundamental fundamental) {}

    public record BrapiFundamental(
            BigDecimal dividendYield,
            BigDecimal pL,
            BigDecimal pVp,
            BigDecimal lucroPorAcao,
            BigDecimal valorPatrimonialPorAcao) {}
}
