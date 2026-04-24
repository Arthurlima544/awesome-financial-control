package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.MonthlyStatsResponse;
import com.awesome.financial.control.afc.dto.NetWorthPoint;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.BillRepository;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StatsService {

    private static final int MONTHS_BACK = 6;
    private static final int EVOLUTION_MONTHS = 12;

    private final TransactionRepository transactionRepository;
    private final InvestmentRepository investmentRepository;
    private final BillRepository billRepository;

    @Transactional(readOnly = true)
    public List<MonthlyStatsResponse> getMonthlyStats() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        List<MonthlyStatsResponse> result = new ArrayList<>(MONTHS_BACK);

        for (int i = MONTHS_BACK - 1; i >= 0; i--) {
            YearMonth month = current.minusMonths(i);
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

            result.add(
                    MonthlyStatsResponse.builder()
                            .month(month.toString())
                            .income(income)
                            .expenses(expenses)
                            .build());
        }
        return result;
    }

    @Transactional(readOnly = true)
    public List<NetWorthPoint> getNetWorthEvolution() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        List<NetWorthPoint> result = new ArrayList<>(EVOLUTION_MONTHS);

        List<Investment> allInvestments = investmentRepository.findAll();

        for (int i = EVOLUTION_MONTHS - 1; i >= 0; i--) {
            YearMonth month = current.minusMonths(i);
            Instant endOfMonth = month.atEndOfMonth().atTime(23, 59, 59).toInstant(ZoneOffset.UTC);

            // 1. Cash Assets (Cumulative Balance)
            BigDecimal incomeAllTime =
                    transactionRepository
                            .sumAmountByTypeAndOccurredAtBefore(TransactionType.INCOME, endOfMonth)
                            .orElse(BigDecimal.ZERO);
            BigDecimal expensesAllTime =
                    transactionRepository
                            .sumAmountByTypeAndOccurredAtBefore(TransactionType.EXPENSE, endOfMonth)
                            .orElse(BigDecimal.ZERO);
            BigDecimal cash = incomeAllTime.subtract(expensesAllTime);

            // 2. Investment Assets
            BigDecimal investments =
                    allInvestments.stream()
                            .filter(inv -> !inv.getCreatedAt().isAfter(endOfMonth))
                            .map(inv -> inv.getQuantity().multiply(inv.getCurrentPrice()))
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

            // 3. Liabilities (Current month's bills as a proxy)
            BigDecimal liabilities =
                    billRepository.findAll().stream()
                            .map(b -> b.getAmount())
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal assets = cash.add(investments);
            BigDecimal total = assets.subtract(liabilities);

            result.add(
                    NetWorthPoint.builder()
                            .month(month.toString())
                            .assets(assets)
                            .liabilities(liabilities)
                            .total(total)
                            .build());
        }

        return result;
    }
}
