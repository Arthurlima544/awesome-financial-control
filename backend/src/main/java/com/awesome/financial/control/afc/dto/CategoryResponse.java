package com.awesome.financial.control.afc.dto;

import java.time.Instant;
import java.util.UUID;
import lombok.Builder;

@Builder
public record CategoryResponse(UUID id, String name, Instant createdAt) {}
