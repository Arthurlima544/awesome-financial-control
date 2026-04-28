package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CreateTransactionRequest;
import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.SummaryResponse;
import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.dto.UpdateTransactionRequest;
import com.awesome.financial.control.afc.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Validated
@Tag(name = "Transactions")
public class TransactionController {

    private final TransactionService transactionService;

    @GetMapping("/transactions")
    @Operation(
            summary =
                    "List transactions ordered by date descending; use limit for last N (dashboard) or page/size for pagination")
    @ApiResponse(responseCode = "200", description = "List of transactions")
    public ResponseEntity<?> getTransactions(
            @RequestParam(required = false) @Min(1) @Max(50) Integer limit,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") @Max(100) int size) {
        if (limit != null) {
            return ResponseEntity.ok(transactionService.getLastTransactions(limit));
        }
        return ResponseEntity.ok(transactionService.getAllTransactions(PageRequest.of(page, size)));
    }

    @DeleteMapping("/transactions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a transaction by id")
    @ApiResponse(responseCode = "204", description = "Transaction deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Transaction not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void deleteTransaction(@PathVariable UUID id) {
        transactionService.deleteTransaction(id);
    }

    @PutMapping("/transactions/{id}")
    @Operation(summary = "Update a transaction")
    @ApiResponse(responseCode = "200", description = "Transaction updated")
    @ApiResponse(
            responseCode = "404",
            description = "Transaction not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public TransactionResponse updateTransaction(
            @PathVariable UUID id, @Valid @RequestBody UpdateTransactionRequest request) {
        return transactionService.updateTransaction(id, request);
    }

    @PostMapping("/transactions")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new transaction")
    @ApiResponse(responseCode = "201", description = "Transaction created")
    @ApiResponse(
            responseCode = "409",
            description = "Linked investment not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public TransactionResponse createTransaction(
            @Valid @RequestBody CreateTransactionRequest request) {
        return transactionService.createTransaction(request);
    }

    @PostMapping("/transactions/bulk")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create multiple transactions")
    @ApiResponse(responseCode = "201", description = "Transactions created")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public List<TransactionResponse> createTransactionsBulk(
            @Valid @RequestBody List<CreateTransactionRequest> requests) {
        return transactionService.createTransactionsBulk(requests);
    }

    @GetMapping("/summary")
    @Operation(summary = "Current month financial summary: income, expenses, balance")
    @ApiResponse(responseCode = "200", description = "Financial summary")
    public SummaryResponse getSummary() {
        return transactionService.getCurrentMonthSummary();
    }
}
