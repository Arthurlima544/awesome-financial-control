package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.service.InvestmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/investments")
@RequiredArgsConstructor
@Validated
@Tag(name = "Investments")
public class InvestmentController {

    private final InvestmentService investmentService;

    @GetMapping
    @Operation(summary = "List all investments")
    public List<InvestmentResponse> getAllInvestments() {
        return investmentService.getAllInvestments();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new investment")
    public InvestmentResponse createInvestment(@Valid @RequestBody InvestmentRequest request) {
        return investmentService.createInvestment(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing investment")
    public InvestmentResponse updateInvestment(
            @PathVariable UUID id, @Valid @RequestBody InvestmentRequest request) {
        return investmentService.updateInvestment(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete an investment")
    public void deleteInvestment(@PathVariable UUID id) {
        investmentService.deleteInvestment(id);
    }

    @PatchMapping("/{id}/price")
    @Operation(summary = "Update investment current price")
    public InvestmentResponse updatePrice(
            @PathVariable UUID id, @RequestParam @DecimalMin("0.01") BigDecimal price) {
        return investmentService.updatePrice(id, price);
    }
}
