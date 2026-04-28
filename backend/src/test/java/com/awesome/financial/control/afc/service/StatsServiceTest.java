package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.MonthlyStatsResponse;
import com.awesome.financial.control.afc.dto.NetWorthPoint;
import com.awesome.financial.control.afc.model.Bill;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.BillRepository;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
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
class StatsServiceTest {

    @Mock private TransactionRepository transactionRepository;
    @Mock private InvestmentRepository investmentRepository;
    @Mock private BillRepository billRepository;

    @InjectMocks private StatsService statsService;

    @Test
    void getMonthlyStats_returnsCorrectIncomeExpenseSeries() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.INCOME), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("3000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBetween(
                        eq(TransactionType.EXPENSE), any(), any()))
                .thenReturn(Optional.of(new BigDecimal("1000.00")));

        List<MonthlyStatsResponse> result = statsService.getMonthlyStats();

        assertThat(result).hasSize(6);
        result.forEach(
                month -> {
                    assertThat(month.income()).isEqualByComparingTo("3000.00");
                    assertThat(month.expenses()).isEqualByComparingTo("1000.00");
                    assertThat(month.month()).isNotBlank();
                });
    }

    @Test
    void getNetWorthEvolution_correctCumulativeCashFlow() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBefore(
                        eq(TransactionType.INCOME), any()))
                .thenReturn(Optional.of(new BigDecimal("10000.00")));
        when(transactionRepository.sumAmountByTypeAndOccurredAtBefore(
                        eq(TransactionType.EXPENSE), any()))
                .thenReturn(Optional.of(new BigDecimal("4000.00")));

        Bill bill = new Bill();
        bill.setAmount(new BigDecimal("500.00"));
        when(billRepository.findAll()).thenReturn(List.of(bill));
        when(investmentRepository.findAll()).thenReturn(List.of());

        List<NetWorthPoint> result = statsService.getNetWorthEvolution();

        assertThat(result).hasSize(12);
        // cash = income - expenses = 6000; liabilities = 500; total = 5500
        result.forEach(
                point -> {
                    assertThat(point.assets()).isEqualByComparingTo("6000.00");
                    assertThat(point.liabilities()).isEqualByComparingTo("500.00");
                    assertThat(point.total()).isEqualByComparingTo("5500.00");
                });
    }

    @Test
    void getNetWorthEvolution_fetchesBillsOnce_notPerMonth() {
        when(transactionRepository.sumAmountByTypeAndOccurredAtBefore(any(), any()))
                .thenReturn(Optional.empty());
        when(billRepository.findAll()).thenReturn(List.of());
        when(investmentRepository.findAll()).thenReturn(List.of());

        statsService.getNetWorthEvolution();

        // 12-month loop must not call billRepository once per iteration
        verify(billRepository, times(1)).findAll();
    }
}
