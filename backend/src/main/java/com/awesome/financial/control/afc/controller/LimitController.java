package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.LimitProgressResponse;
import com.awesome.financial.control.afc.service.LimitService;
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
@Tag(name = "Limits")
public class LimitController {

    private final LimitService limitService;

    @GetMapping("/limits/progress")
    @Operation(summary = "Current month spending progress for all limits")
    public List<LimitProgressResponse> getLimitsProgress() {
        return limitService.getLimitsWithProgress();
    }
}
