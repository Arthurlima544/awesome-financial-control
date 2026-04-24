package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;

public record CompoundInterestResponse(
        BigDecimal finalAmount,
        BigDecimal totalInvested,
        BigDecimal totalInterest,
        List<TimelineEntry> timeline) {
    public record TimelineEntry(double year, BigDecimal invested, BigDecimal accumulated) {}
}
