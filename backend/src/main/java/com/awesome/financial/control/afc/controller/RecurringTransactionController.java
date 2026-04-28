package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.service.RecurringTransactionService;
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
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/recurring")
@RequiredArgsConstructor
@Tag(name = "Recurring Transactions")
public class RecurringTransactionController {

    private final RecurringTransactionService recurringService;

    @GetMapping
    @Operation(summary = "List all recurring transaction rules")
    @ApiResponse(responseCode = "200", description = "List of recurring rules")
    public List<RecurringTransactionResponse> getAll() {
        return recurringService.findAll();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new recurring transaction rule")
    @ApiResponse(responseCode = "201", description = "Recurring rule created")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public RecurringTransactionResponse create(
            @RequestBody @Valid RecurringTransactionRequest request) {
        return recurringService.create(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing recurring transaction rule")
    @ApiResponse(responseCode = "200", description = "Recurring rule updated")
    @ApiResponse(
            responseCode = "404",
            description = "Recurring rule not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public RecurringTransactionResponse update(
            @PathVariable UUID id, @RequestBody @Valid RecurringTransactionRequest request) {
        return recurringService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a recurring transaction rule")
    @ApiResponse(responseCode = "204", description = "Recurring rule deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Recurring rule not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void delete(@PathVariable UUID id) {
        recurringService.delete(id);
    }

    @PostMapping("/process")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Trigger processing of pending recurring transactions")
    @ApiResponse(responseCode = "202", description = "Processing accepted")
    public void process() {
        recurringService.processPending();
    }
}
