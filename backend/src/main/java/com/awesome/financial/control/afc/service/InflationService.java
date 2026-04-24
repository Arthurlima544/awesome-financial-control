package com.awesome.financial.control.afc.service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import org.springframework.stereotype.Service;

@Service
public class InflationService {

    /** Default annual inflation rate (IPCA) as per US-66. 4.5% per year. */
    public static final BigDecimal DEFAULT_INFLATION_RATE = BigDecimal.valueOf(0.045);

    /**
     * Adjusts a nominal interest rate to a real interest rate using the Fisher equation: realRate =
     * (1 + nominalRate) / (1 + inflationRate) - 1
     *
     * @param nominalRate the nominal annual interest rate (e.g., 0.10 for 10%)
     * @return the real annual interest rate
     */
    public BigDecimal adjustRate(BigDecimal nominalRate) {
        if (nominalRate == null) return BigDecimal.ZERO;

        BigDecimal onePlusNominal = BigDecimal.ONE.add(nominalRate);
        BigDecimal onePlusInflation = BigDecimal.ONE.add(DEFAULT_INFLATION_RATE);

        BigDecimal realRate =
                onePlusNominal
                        .divide(onePlusInflation, MathContext.DECIMAL128)
                        .subtract(BigDecimal.ONE);

        return realRate.setScale(10, RoundingMode.HALF_UP);
    }

    /**
     * Calculates the real value of a nominal amount after a certain number of years. realValue =
     * nominalValue / (1 + inflationRate)^years
     *
     * @param nominalValue the nominal amount
     * @param years the number of years
     * @return the real value in today's currency
     */
    public BigDecimal calculateRealValue(BigDecimal nominalValue, int years) {
        if (nominalValue == null || years <= 0) return nominalValue;

        BigDecimal onePlusInflation = BigDecimal.ONE.add(DEFAULT_INFLATION_RATE);
        BigDecimal divisor = onePlusInflation.pow(years, MathContext.DECIMAL128);

        return nominalValue.divide(divisor, 2, RoundingMode.HALF_UP);
    }
}
