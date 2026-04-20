package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.MonthlyStatsResponse;
import com.awesome.financial.control.afc.model.TransactionType;
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

    private final TransactionRepository transactionRepository;

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
}
