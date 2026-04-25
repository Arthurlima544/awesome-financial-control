package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.util.UUID;
import lombok.Builder;

@Builder
public record CreateLimitRequest(
        @NotNull(message = "Category ID is required") UUID categoryId,
        @NotNull(message = "Amount is required") @Positive(message = "Amount must be positive")
                BigDecimal amount) {}
