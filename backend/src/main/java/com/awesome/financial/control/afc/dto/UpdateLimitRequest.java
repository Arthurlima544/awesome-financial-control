package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public record UpdateLimitRequest(@NotNull @DecimalMin("0.01") BigDecimal amount) {}
