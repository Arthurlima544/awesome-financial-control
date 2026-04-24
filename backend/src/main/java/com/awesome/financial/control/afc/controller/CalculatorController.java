package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CompoundInterestRequest;
import com.awesome.financial.control.afc.dto.CompoundInterestResponse;
import com.awesome.financial.control.afc.dto.FireCalculationRequest;
import com.awesome.financial.control.afc.dto.FireCalculationResponse;
import com.awesome.financial.control.afc.dto.InvestmentGoalRequest;
import com.awesome.financial.control.afc.dto.InvestmentGoalResponse;
import com.awesome.financial.control.afc.service.CalculatorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/calculators")
@RequiredArgsConstructor
@Validated
@Tag(name = "Calculators")
public class CalculatorController {

    private final CalculatorService calculatorService;

    @Operation(summary = "Calculate FIRE number and timeline")
    @PostMapping("/fire")
    public FireCalculationResponse calculateFire(
            @RequestBody @Valid FireCalculationRequest request) {
        return calculatorService.calculateFire(request);
    }

    @Operation(summary = "Calculate compound interest timeline")
    @PostMapping("/compound-interest")
    public CompoundInterestResponse calculateCompoundInterest(
            @RequestBody @Valid CompoundInterestRequest request) {
        return calculatorService.calculateCompoundInterest(request);
    }

    @Operation(summary = "Calculate required monthly investment for a target goal")
    @PostMapping("/investment-goal")
    public InvestmentGoalResponse calculateInvestmentGoal(
            @RequestBody @Valid InvestmentGoalRequest request) {
        return calculatorService.calculateInvestmentGoal(request);
    }
}
