package com.awesome.financial.control.afc.dto;

import java.time.Instant;

public record ErrorResponse(
        String code, String message, int status, String path, Instant timestamp) {

    public ErrorResponse(String code, String message, int status, String path) {
        this(code, message, status, path, Instant.now());
    }
}
