package com.awesome.financial.control.afc.dto;

import java.util.List;
import lombok.Builder;

@Builder
public record HealthScoreResponse(
        int score,
        int savingsScore,
        int limitsScore,
        int goalsScore,
        int varianceScore,
        List<Integer> historicalScores) {}
