package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.MonthlyReportResponse;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final TransactionRepository transactionRepository;

    @Transactional(readOnly = true)
    public MonthlyReportResponse getMonthlyReport(YearMonth month) {
        Instant from = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = month.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        YearMonth prevMonth = month.minusMonths(1);
        Instant prevFrom = prevMonth.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant prevTo = month.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        BigDecimal income =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.INCOME, from, to)
                        .orElse(BigDecimal.ZERO);
        BigDecimal expenses =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.EXPENSE, from, to)
                        .orElse(BigDecimal.ZERO);

        BigDecimal savingsRate = BigDecimal.ZERO;
        if (income.compareTo(BigDecimal.ZERO) > 0) {
            savingsRate =
                    income.subtract(expenses)
                            .multiply(new BigDecimal("100"))
                            .divide(income, 2, RoundingMode.HALF_UP);
        }

        List<Object[]> currentCategories =
                transactionRepository.sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                        TransactionType.EXPENSE, from, to);
        List<Object[]> previousCategories =
                transactionRepository.sumAmountByTypeGroupByCategoryAndOccurredAtBetween(
                        TransactionType.EXPENSE, prevFrom, prevTo);

        Map<String, BigDecimal> prevMap = new HashMap<>();
        for (Object[] obj : previousCategories) {
            prevMap.put((String) obj[0], (BigDecimal) obj[1]);
        }

        List<MonthlyReportResponse.CategoryBreakdown> breakdowns = new ArrayList<>();
        List<MonthlyReportResponse.CategoryComparison> comparisons = new ArrayList<>();

        for (Object[] obj : currentCategories) {
            String category = (String) obj[0];
            BigDecimal amount = (BigDecimal) obj[1];
            double percentage = 0;
            if (expenses.compareTo(BigDecimal.ZERO) > 0) {
                percentage =
                        amount.multiply(new BigDecimal("100"))
                                .divide(expenses, 2, RoundingMode.HALF_UP)
                                .doubleValue();
            }

            breakdowns.add(
                    new MonthlyReportResponse.CategoryBreakdown(category, amount, percentage));
            comparisons.add(
                    new MonthlyReportResponse.CategoryComparison(
                            category, amount, prevMap.getOrDefault(category, BigDecimal.ZERO)));
        }

        // Add categories that were in previous month but not in current
        for (Map.Entry<String, BigDecimal> entry : prevMap.entrySet()) {
            if (currentCategories.stream()
                    .noneMatch(obj -> java.util.Objects.equals(obj[0], entry.getKey()))) {
                comparisons.add(
                        new MonthlyReportResponse.CategoryComparison(
                                entry.getKey(), BigDecimal.ZERO, entry.getValue()));
            }
        }

        return MonthlyReportResponse.builder()
                .totalIncome(income)
                .totalExpenses(expenses)
                .savingsRate(savingsRate)
                .categories(breakdowns)
                .comparison(comparisons)
                .build();
    }
}
