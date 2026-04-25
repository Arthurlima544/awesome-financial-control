package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.UUID;

public record FeedbackRequest(
        UUID userId,
        @Min(1) @Max(5) int rating,
        String message,
        @NotBlank String appVersion,
        @NotBlank String platform) {}
