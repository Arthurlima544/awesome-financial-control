package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Builder;

@Builder
public record GoalResponse(
        UUID id,
        String name,
        BigDecimal targetAmount,
        BigDecimal currentAmount,
        BigDecimal progressPercentage,
        Instant deadline,
        String icon,
        Instant createdAt) {}
