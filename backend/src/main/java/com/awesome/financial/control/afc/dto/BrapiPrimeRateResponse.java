package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.List;

public record BrapiPrimeRateResponse(List<PrimeRate> countryPrimeRate) {
    public record PrimeRate(String name, BigDecimal value) {}
}
