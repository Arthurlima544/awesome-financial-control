package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.TransactionType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.Instant;

public record CreateTransactionRequest(
        @NotBlank String description,
        @NotNull @DecimalMin("0.01") BigDecimal amount,
        @NotNull TransactionType type,
        String category,
        @NotNull Instant occurredAt,
        boolean isPassive,
        java.util.UUID investmentId) {}
