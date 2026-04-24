package com.awesome.financial.control.afc.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class InflationServiceTest {

    private final InflationService inflationService = new InflationService();

    @Test
    void shouldAdjustRateCorrectly() {
        // (1 + 0.10) / (1 + 0.045) - 1 = 1.10 / 1.045 - 1 = 0.0526315789
        BigDecimal nominalRate = BigDecimal.valueOf(0.10);
        BigDecimal realRate = inflationService.adjustRate(nominalRate);

        assertEquals(0, realRate.compareTo(new BigDecimal("0.0526315789")));
    }

    @Test
    void shouldHandleZeroNominalRate() {
        // (1 + 0) / (1 + 0.045) - 1 = 1 / 1.045 - 1 = -0.0430622009
        BigDecimal nominalRate = BigDecimal.ZERO;
        BigDecimal realRate = inflationService.adjustRate(nominalRate);

        assertTrue(realRate.compareTo(BigDecimal.ZERO) < 0);
        assertEquals(0, realRate.compareTo(new BigDecimal("-0.0430622010")));
    }

    @Test
    void shouldCalculateRealValueCorrectly() {
        // 1000 / (1 + 0.045)^10 = 1000 / 1.552969 = 643.93
        BigDecimal nominalValue = BigDecimal.valueOf(1000);
        BigDecimal realValue = inflationService.calculateRealValue(nominalValue, 10);

        assertEquals(new BigDecimal("643.93"), realValue);
    }

    @Test
    void shouldReturnSameValueForZeroYears() {
        BigDecimal nominalValue = BigDecimal.valueOf(1000);
        BigDecimal realValue = inflationService.calculateRealValue(nominalValue, 0);

        assertEquals(nominalValue, realValue);
    }
}
