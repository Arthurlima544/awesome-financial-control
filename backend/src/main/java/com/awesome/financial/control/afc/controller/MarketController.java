package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.MarketBenchmarkDTO;
import com.awesome.financial.control.afc.dto.MarketOpportunityDTO;
import com.awesome.financial.control.afc.service.MarketService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/market")
@RequiredArgsConstructor
@Tag(name = "Market", description = "Endpoints for market opportunities and benchmarks")
public class MarketController {

    private final MarketService marketService;

    @GetMapping("/opportunities")
    @Operation(summary = "Get curated market opportunities (stocks and FIIs)")
    public List<MarketOpportunityDTO> getOpportunities() {
        return marketService.getOpportunities();
    }

    @GetMapping("/benchmarks")
    @Operation(summary = "Get current market benchmarks (CDI, Selic)")
    public MarketBenchmarkDTO getBenchmarks() {
        return marketService.getBenchmarks();
    }
}
