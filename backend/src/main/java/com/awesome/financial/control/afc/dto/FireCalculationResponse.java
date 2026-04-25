package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record FireCalculationResponse(
        BigDecimal fireNumber,
        int monthsToFire,
        LocalDate retirementDate,
        double fiScore,
        List<FireTimelineEntry> yearlyTimeline) {
    public record FireTimelineEntry(double year, BigDecimal portfolioValue) {}
}
