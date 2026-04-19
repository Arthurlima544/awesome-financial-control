package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.SummaryResponse;
import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.service.TransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Validated
@Tag(name = "Transactions")
public class TransactionController {

    private final TransactionService transactionService;

    @GetMapping("/transactions")
    @Operation(summary = "List last N transactions ordered by date descending")
    public List<TransactionResponse> getTransactions(
            @RequestParam(defaultValue = "5") @Min(1) @Max(50) int limit) {
        return transactionService.getLastTransactions(limit);
    }

    @GetMapping("/summary")
    @Operation(summary = "Current month financial summary: income, expenses, balance")
    public SummaryResponse getSummary() {
        return transactionService.getCurrentMonthSummary();
    }
}
