package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.TransactionType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateTemplateRequest(
        @NotBlank String description, String category, @NotNull TransactionType type) {}
