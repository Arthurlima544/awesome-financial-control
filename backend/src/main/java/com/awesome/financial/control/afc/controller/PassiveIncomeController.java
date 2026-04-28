package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.PassiveIncomeDashboardResponse;
import com.awesome.financial.control.afc.service.PassiveIncomeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/passive-income")
@RequiredArgsConstructor
@Tag(name = "Passive Income")
public class PassiveIncomeController {

    private final PassiveIncomeService passiveIncomeService;

    @GetMapping("/dashboard")
    @Operation(summary = "Get passive income dashboard data")
    @ApiResponse(responseCode = "200", description = "Passive income dashboard")
    public PassiveIncomeDashboardResponse getDashboardData() {
        return passiveIncomeService.getDashboardData();
    }
}
