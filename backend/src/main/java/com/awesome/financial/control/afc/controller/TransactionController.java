package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CreateTransactionRequest;
import com.awesome.financial.control.afc.dto.SummaryResponse;
import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.dto.UpdateTransactionRequest;
import com.awesome.financial.control.afc.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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
    @Operation(summary = "List transactions ordered by date descending; omit limit to get all")
    public List<TransactionResponse> getTransactions(
            @RequestParam(required = false) @Min(1) @Max(50) Integer limit) {
        return limit != null
                ? transactionService.getLastTransactions(limit)
                : transactionService.getAllTransactions();
    }

    @DeleteMapping("/transactions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a transaction by id")
    public void deleteTransaction(@PathVariable UUID id) {
        transactionService.deleteTransaction(id);
    }

    @PutMapping("/transactions/{id}")
    @Operation(summary = "Update a transaction")
    public TransactionResponse updateTransaction(
            @PathVariable UUID id, @Valid @RequestBody UpdateTransactionRequest request) {
        return transactionService.updateTransaction(id, request);
    }

    @PostMapping("/transactions")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new transaction")
    public TransactionResponse createTransaction(
            @Valid @RequestBody CreateTransactionRequest request) {
        return transactionService.createTransaction(request);
    }

    @GetMapping("/summary")
    @Operation(summary = "Current month financial summary: income, expenses, balance")
    public SummaryResponse getSummary() {
        return transactionService.getCurrentMonthSummary();
    }
}
