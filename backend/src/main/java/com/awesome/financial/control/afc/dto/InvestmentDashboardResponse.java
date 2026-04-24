package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.InvestmentType;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public record InvestmentDashboardResponse(
        BigDecimal totalInvested,
        BigDecimal currentTotalValue,
        BigDecimal totalProfitLoss,
        double totalProfitLossPercentage,
        Map<InvestmentType, BigDecimal> allocationByType,
        List<AssetPerformance> assetPerformance) {
    public record AssetPerformance(
            String ticker, String name, BigDecimal profitLoss, double percentage) {}
}
