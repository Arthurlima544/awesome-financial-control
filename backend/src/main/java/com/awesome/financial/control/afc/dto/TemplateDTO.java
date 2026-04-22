package com.awesome.financial.control.afc.dto;

import com.awesome.financial.control.afc.model.TransactionType;
import java.util.UUID;

public record TemplateDTO(UUID id, String description, String category, TransactionType type) {}
