package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.MonthlyStatsResponse;
import com.awesome.financial.control.afc.service.StatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Stats")
public class StatsController {

    private final StatsService statsService;

    @GetMapping("/stats/monthly")
    @Operation(summary = "Monthly income and expenses for the last 6 months")
    public List<MonthlyStatsResponse> getMonthlyStats() {
        return statsService.getMonthlyStats();
    }
}
