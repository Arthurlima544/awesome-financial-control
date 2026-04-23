package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.HealthScoreResponse;
import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.GoalRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class HealthScoreServiceTest {

    @Mock private TransactionRepository transactionRepository;
    @Mock private LimitRepository limitRepository;
    @Mock private GoalRepository goalRepository;

    @InjectMocks private HealthScoreService healthScoreService;

    @Test
    void shouldCalculatePerfectScore() {
        // Savings: 5000 income, 1000 expenses -> 80% savings rate -> 25 pts
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.INCOME), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("5000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1000.00")));

        // Limits: 1 limit, spent 500/1000 -> 25 pts
        Category cat = new Category();
        cat.setName("Food");
        Limit limit = Limit.builder().category(cat).amount(new BigDecimal("1000.00")).build();
        when(limitRepository.findAllWithCategory()).thenReturn(List.of(limit));
        when(transactionRepository.sumAmountByTypeAndCategoryAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), eq("Food"), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("500.00")));

        // Goals: 1 goal, 1000/1000 progress -> 25 pts
        Goal goal =
                Goal.builder()
                        .targetAmount(new BigDecimal("1000.00"))
                        .currentAmount(new BigDecimal("1000.00"))
                        .build();
        when(goalRepository.findAll()).thenReturn(List.of(goal));

        HealthScoreResponse response = healthScoreService.getHealthScore();

        assertThat(response.score()).isEqualTo(100);
        assertThat(response.savingsScore()).isEqualTo(25);
        assertThat(response.limitsScore()).isEqualTo(25);
        assertThat(response.goalsScore()).isEqualTo(25);
        assertThat(response.varianceScore()).isEqualTo(25);
    }

    @Test
    void shouldCalculateLowScore() {
        // Savings: 1000 income, 1000 expenses -> 0% savings rate -> 0 pts
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.INCOME), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1000.00")));

        // Limits: 1 limit, spent 1500/1000 -> 0 pts
        Category cat = new Category();
        cat.setName("Food");
        Limit limit = Limit.builder().category(cat).amount(new BigDecimal("1000.00")).build();
        when(limitRepository.findAllWithCategory()).thenReturn(List.of(limit));
        when(transactionRepository.sumAmountByTypeAndCategoryAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), eq("Food"), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1500.00")));

        // Goals: 1 goal, 0/1000 progress -> 0 pts
        Goal goal =
                Goal.builder()
                        .targetAmount(new BigDecimal("1000.00"))
                        .currentAmount(BigDecimal.ZERO)
                        .build();
        when(goalRepository.findAll()).thenReturn(List.of(goal));

        // Variance: 1000 expenses vs 500 average -> 50% ratio -> 12 pts
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(
                        Optional.of(new BigDecimal("1000.00")), // current
                        Optional.of(new BigDecimal("500.00"))); // past month 1

        HealthScoreResponse response = healthScoreService.getHealthScore();

        assertThat(response.score()).isLessThan(50);
        assertThat(response.savingsScore()).isEqualTo(0);
        assertThat(response.limitsScore()).isEqualTo(0);
        assertThat(response.goalsScore()).isEqualTo(0);
    }
}
