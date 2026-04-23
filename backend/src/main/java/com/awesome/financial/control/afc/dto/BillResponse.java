package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record BillResponse(
        UUID id, String name, BigDecimal amount, Integer dueDay, String categoryId) {}
