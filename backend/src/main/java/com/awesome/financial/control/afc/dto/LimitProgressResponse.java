package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.UUID;
import lombok.Builder;

@Builder
public record LimitProgressResponse(
        UUID id,
        String categoryName,
        BigDecimal limitAmount,
        BigDecimal spent,
        double percentage) {}
