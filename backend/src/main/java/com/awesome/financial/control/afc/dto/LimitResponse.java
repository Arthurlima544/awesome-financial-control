package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Builder;

@Builder
public record LimitResponse(UUID id, String categoryName, BigDecimal amount, Instant createdAt) {}
