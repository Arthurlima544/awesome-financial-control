package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.InvestmentDashboardResponse;
import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.service.InvestmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
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

    @GetMapping("/dashboard")
    @Operation(summary = "Get investment dashboard data")
    @ApiResponse(responseCode = "200", description = "Investment dashboard data")
    public InvestmentDashboardResponse getDashboardData() {
        return investmentService.getDashboardData();
    }

    @GetMapping
    @Operation(summary = "List all investments")
    @ApiResponse(responseCode = "200", description = "List of investments")
    public List<InvestmentResponse> getAllInvestments() {
        return investmentService.getAllInvestments();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new investment")
    @ApiResponse(responseCode = "201", description = "Investment created")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public InvestmentResponse createInvestment(@Valid @RequestBody InvestmentRequest request) {
        return investmentService.createInvestment(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing investment")
    @ApiResponse(responseCode = "200", description = "Investment updated")
    @ApiResponse(
            responseCode = "404",
            description = "Investment not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public InvestmentResponse updateInvestment(
            @PathVariable UUID id, @Valid @RequestBody InvestmentRequest request) {
        return investmentService.updateInvestment(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete an investment")
    @ApiResponse(responseCode = "204", description = "Investment deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Investment not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "409",
            description = "Investment has associated transactions",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void deleteInvestment(@PathVariable UUID id) {
        investmentService.deleteInvestment(id);
    }

    @PatchMapping("/{id}/price")
    @Operation(summary = "Update investment current price")
    @ApiResponse(responseCode = "200", description = "Price updated")
    @ApiResponse(
            responseCode = "404",
            description = "Investment not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public InvestmentResponse updatePrice(
            @PathVariable UUID id, @RequestParam @DecimalMin("0.01") BigDecimal price) {
        return investmentService.updatePrice(id, price);
    }
}
