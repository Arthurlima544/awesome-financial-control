package com.awesome.financial.control.afc.dto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record BillRequest(String name, BigDecimal amount, Integer dueDay, String categoryId) {}
