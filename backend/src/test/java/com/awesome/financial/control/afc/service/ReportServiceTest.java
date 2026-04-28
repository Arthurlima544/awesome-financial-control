package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.MonthlyReportResponse;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.ArrayList;
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
class ReportServiceTest {

    @Mock private TransactionRepository transactionRepository;

    @InjectMocks private ReportService reportService;

    @Test
    void noTransactionMonth_returnsZeroTotals() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(any(), any(), any()))
                .thenReturn(Optional.empty());
        when(transactionRepository.sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                        any(), any(), any()))
                .thenReturn(List.of());

        MonthlyReportResponse result = reportService.getMonthlyReport(YearMonth.of(2024, 1));

        assertThat(result.totalIncome()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(result.totalExpenses()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(result.savingsRate()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(result.categories()).isEmpty();
    }

    @Test
    void mixedTransactions_yieldCorrectCategoryBreakdown() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.INCOME), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("5000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("2200.00")));

        List<Object[]> current = new ArrayList<>();
        current.add(new Object[] {"Food", new BigDecimal("700.00")});
        current.add(new Object[] {"Housing", new BigDecimal("1500.00")});

        when(transactionRepository.sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(current, List.of());

        MonthlyReportResponse result = reportService.getMonthlyReport(YearMonth.of(2024, 3));

        assertThat(result.totalIncome()).isEqualByComparingTo("5000.00");
        assertThat(result.totalExpenses()).isEqualByComparingTo("2200.00");
        assertThat(result.categories()).hasSize(2);
        assertThat(result.categories())
                .anySatisfy(
                        c -> {
                            assertThat(c.category()).isEqualTo("Food");
                            assertThat(c.amount()).isEqualByComparingTo("700.00");
                        });
        assertThat(result.categories())
                .anySatisfy(
                        c -> {
                            assertThat(c.category()).isEqualTo("Housing");
                            assertThat(c.amount()).isEqualByComparingTo("1500.00");
                        });
    }

    @Test
    void monthOverMonthComparison_isCorrect() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.INCOME), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("5000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1500.00")));

        List<Object[]> currentMonth = new ArrayList<>();
        currentMonth.add(new Object[] {"Housing", new BigDecimal("1500.00")});

        List<Object[]> previousMonth = new ArrayList<>();
        previousMonth.add(new Object[] {"Housing", new BigDecimal("1500.00")});

        // first call → current month categories, second call → previous month categories
        when(transactionRepository.sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(currentMonth, previousMonth);

        MonthlyReportResponse result = reportService.getMonthlyReport(YearMonth.of(2024, 3));

        assertThat(result.comparison()).hasSize(1);
        MonthlyReportResponse.CategoryComparison comp = result.comparison().get(0);
        assertThat(comp.category()).isEqualTo("Housing");
        assertThat(comp.currentAmount()).isEqualByComparingTo("1500.00");
        assertThat(comp.previousAmount()).isEqualByComparingTo("1500.00");
    }
}
