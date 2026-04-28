package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.HealthScoreResponse;
import com.awesome.financial.control.afc.service.HealthScoreService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/health")
@RequiredArgsConstructor
@Tag(name = "Health Score")
public class HealthScoreController {

    private final HealthScoreService healthScoreService;

    @GetMapping("/score")
    @Operation(summary = "Get financial health score and breakdown")
    @ApiResponse(responseCode = "200", description = "Financial health score")
    public HealthScoreResponse getHealthScore() {
        return healthScoreService.getHealthScore();
    }
}
