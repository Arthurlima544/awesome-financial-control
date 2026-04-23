package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.Instant;
import lombok.Builder;

@Builder
public record GoalRequest(
        @NotBlank String name,
        @NotNull @DecimalMin("0.01") BigDecimal targetAmount,
        BigDecimal currentAmount,
        @NotNull Instant deadline,
        String icon) {}
