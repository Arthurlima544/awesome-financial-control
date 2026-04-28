package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.HealthScoreResponse;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.GoalRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class HealthScoreService {

    private final TransactionRepository transactionRepository;
    private final LimitRepository limitRepository;
    private final GoalRepository goalRepository;

    @Transactional(readOnly = true)
    public HealthScoreResponse getHealthScore() {
        YearMonth currentMonth = YearMonth.now(ZoneOffset.UTC);

        int savingsScore = calculateSavingsScore(currentMonth);
        int limitsScore = calculateLimitsScore(currentMonth);
        int goalsScore = calculateGoalsScore();
        int varianceScore = calculateVarianceScore(currentMonth);

        int totalScore = savingsScore + limitsScore + goalsScore + varianceScore;

        List<Integer> historicalScores = new ArrayList<>();
        for (int i = 5; i >= 0; i--) {
            historicalScores.add(calculateTotalScore(currentMonth.minusMonths(i)));
        }

        return HealthScoreResponse.builder()
                .score(totalScore)
                .savingsScore(savingsScore)
                .limitsScore(limitsScore)
                .goalsScore(goalsScore)
                .varianceScore(varianceScore)
                .historicalScores(historicalScores)
                .build();
    }

    private int calculateTotalScore(YearMonth month) {
        return calculateSavingsScore(month)
                + calculateLimitsScore(month)
                + calculateGoalsScore()
                + calculateVarianceScore(month);
    }

    private int calculateSavingsScore(YearMonth month) {
        Instant from = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = month.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        BigDecimal income =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.INCOME, from, to)
                        .orElse(BigDecimal.ZERO);
        BigDecimal expenses =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.EXPENSE, from, to)
                        .orElse(BigDecimal.ZERO);

        if (income.compareTo(BigDecimal.ZERO) <= 0) return 0;

        BigDecimal savings = income.subtract(expenses);
        BigDecimal savingsRate = savings.divide(income, 4, RoundingMode.HALF_UP);

        // 20% savings rate = 25 points
        BigDecimal score = savingsRate.multiply(BigDecimal.valueOf(125));
        return Math.min(25, Math.max(0, score.intValue()));
    }

    private int calculateLimitsScore(YearMonth month) {
        Instant from = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = month.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        List<Limit> limits = limitRepository.findAllWithCategory();
        if (limits.isEmpty()) return 25;

        Map<String, BigDecimal> expensesByCategory =
                transactionRepository
                        .sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                                TransactionType.EXPENSE, from, to)
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        row -> (String) row[0], row -> (BigDecimal) row[1]));

        long exceededCount =
                limits.stream()
                        .filter(
                                limit -> {
                                    BigDecimal spent =
                                            expensesByCategory.getOrDefault(
                                                    limit.getCategory().getName(), BigDecimal.ZERO);
                                    return spent.compareTo(limit.getAmount()) > 0;
                                })
                        .count();

        double adherenceRate = (double) (limits.size() - exceededCount) / limits.size();
        return (int) (adherenceRate * 25);
    }

    private int calculateGoalsScore() {
        List<Goal> goals = goalRepository.findAll();
        if (goals.isEmpty()) return 25;

        double totalProgress =
                goals.stream()
                        .mapToDouble(
                                g -> {
                                    if (g.getTargetAmount().compareTo(BigDecimal.ZERO) == 0)
                                        return 1.0;
                                    return g.getCurrentAmount()
                                            .divide(g.getTargetAmount(), 4, RoundingMode.HALF_UP)
                                            .doubleValue();
                                })
                        .average()
                        .orElse(0.0);

        return (int) (totalProgress * 25);
    }

    private int calculateVarianceScore(YearMonth month) {
        Instant fromCurrent = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant toCurrent = month.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        BigDecimal currentExpenses =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(
                                TransactionType.EXPENSE, fromCurrent, toCurrent)
                        .orElse(BigDecimal.ZERO);

        BigDecimal totalPastExpenses = BigDecimal.ZERO;
        int monthsWithData = 0;
        for (int i = 1; i <= 3; i++) {
            YearMonth pastMonth = month.minusMonths(i);
            Instant from = pastMonth.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
            Instant to = pastMonth.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
            BigDecimal pastExpenses =
                    transactionRepository
                            .sumAmountByTypeAndOccurredAtBetween(TransactionType.EXPENSE, from, to)
                            .orElse(BigDecimal.ZERO);
            if (pastExpenses.compareTo(BigDecimal.ZERO) > 0) {
                totalPastExpenses = totalPastExpenses.add(pastExpenses);
                monthsWithData++;
            }
        }

        if (monthsWithData == 0) return 25;

        BigDecimal avgPastExpenses =
                totalPastExpenses.divide(
                        BigDecimal.valueOf(monthsWithData), 2, RoundingMode.HALF_UP);
        if (currentExpenses.compareTo(avgPastExpenses) <= 0) return 25;

        // Scale down if current is higher than average
        BigDecimal ratio = avgPastExpenses.divide(currentExpenses, 4, RoundingMode.HALF_UP);
        return (int) (ratio.doubleValue() * 25);
    }
}
