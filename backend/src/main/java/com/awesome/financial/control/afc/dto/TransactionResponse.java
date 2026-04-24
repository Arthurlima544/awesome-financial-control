package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.TransactionType;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Builder;

@Builder
public record TransactionResponse(
        UUID id,
        String description,
        BigDecimal amount,
        TransactionType type,
        String category,
        Instant occurredAt,
        boolean isPassive,
        UUID investmentId) {}
