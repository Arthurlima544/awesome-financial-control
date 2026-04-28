package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CreateLimitRequest;
import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.LimitProgressResponse;
import com.awesome.financial.control.afc.dto.LimitResponse;
import com.awesome.financial.control.afc.dto.UpdateLimitRequest;
import com.awesome.financial.control.afc.service.LimitService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Limits")
public class LimitController {

    private final LimitService limitService;

    @PostMapping("/limits")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new spending limit")
    @ApiResponse(responseCode = "201", description = "Limit created")
    @ApiResponse(
            responseCode = "409",
            description = "Limit already exists for this category",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public LimitResponse createLimit(@Valid @RequestBody CreateLimitRequest request) {
        return limitService.createLimit(request);
    }

    @GetMapping("/limits")
    @Operation(summary = "List all spending limits")
    @ApiResponse(responseCode = "200", description = "List of spending limits")
    public List<LimitResponse> getLimits() {
        return limitService.getAllLimits();
    }

    @DeleteMapping("/limits/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a spending limit by id")
    @ApiResponse(responseCode = "204", description = "Limit deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Limit not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void deleteLimit(@PathVariable UUID id) {
        limitService.deleteLimit(id);
    }

    @PutMapping("/limits/{id}")
    @Operation(summary = "Update a spending limit amount")
    @ApiResponse(responseCode = "200", description = "Limit updated")
    @ApiResponse(
            responseCode = "404",
            description = "Limit not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public LimitResponse updateLimit(
            @PathVariable UUID id, @Valid @RequestBody UpdateLimitRequest request) {
        return limitService.updateLimit(id, request);
    }

    @GetMapping("/limits/progress")
    @Operation(summary = "Current month spending progress for all limits")
    @ApiResponse(responseCode = "200", description = "Limit progress data")
    public List<LimitProgressResponse> getLimitsProgress() {
        return limitService.getLimitsWithProgress();
    }
}
