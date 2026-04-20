package com.awesome.financial.control.afc.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateCategoryRequest(@NotBlank String name) {}
