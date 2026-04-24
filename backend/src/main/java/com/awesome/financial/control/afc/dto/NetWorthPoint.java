package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record NetWorthPoint(
        String month, BigDecimal assets, BigDecimal liabilities, BigDecimal total) {}
