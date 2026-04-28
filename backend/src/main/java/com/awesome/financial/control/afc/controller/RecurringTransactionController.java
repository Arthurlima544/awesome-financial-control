package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.service.RecurringTransactionService;
import io.swagger.v3.oas.annotations.Operation;
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
    public List<RecurringTransactionResponse> getAll() {
        return recurringService.findAll();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new recurring transaction rule")
    public RecurringTransactionResponse create(
            @RequestBody @Valid RecurringTransactionRequest request) {
        return recurringService.create(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing recurring transaction rule")
    public RecurringTransactionResponse update(
            @PathVariable UUID id, @RequestBody @Valid RecurringTransactionRequest request) {
        return recurringService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a recurring transaction rule")
    public void delete(@PathVariable UUID id) {
        recurringService.delete(id);
    }

    @PostMapping("/process")
    @ResponseStatus(HttpStatus.ACCEPTED)
    @Operation(summary = "Trigger processing of pending recurring transactions")
    public void process() {
        recurringService.processPending();
    }
}
