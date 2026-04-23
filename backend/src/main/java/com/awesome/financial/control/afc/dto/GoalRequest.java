package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.time.Instant;
import lombok.Builder;

@Builder
public record GoalRequest(
        String name,
        BigDecimal targetAmount,
        BigDecimal currentAmount,
        Instant deadline,
        String icon) {}
