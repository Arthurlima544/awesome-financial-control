package com.awesome.financial.control.afc.dto;

import java.time.Instant;
import java.util.UUID;

public record FeedbackResponse(
        UUID id,
        UUID userId,
        int rating,
        String message,
        String appVersion,
        String platform,
        Instant createdAt) {}
