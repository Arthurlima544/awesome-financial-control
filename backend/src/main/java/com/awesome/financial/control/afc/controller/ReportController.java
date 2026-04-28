package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.MonthlyReportResponse;
import com.awesome.financial.control.afc.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.YearMonth;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
@Tag(name = "Reports")
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/monthly")
    @Operation(summary = "Get detailed monthly report")
    @ApiResponse(responseCode = "200", description = "Monthly report")
    @ApiResponse(
            responseCode = "400",
            description = "Invalid month format",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public MonthlyReportResponse getMonthlyReport(@RequestParam String month) {
        return reportService.getMonthlyReport(YearMonth.parse(month));
    }
}
