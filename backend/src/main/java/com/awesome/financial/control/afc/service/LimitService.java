package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.LimitProgressResponse;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LimitService {

    private final LimitRepository limitRepository;
    private final TransactionRepository transactionRepository;

    @Transactional(readOnly = true)
    public List<LimitProgressResponse> getLimitsWithProgress() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        Instant from = current.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = current.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        return limitRepository.findAllWithCategory().stream()
                .map(
                        limit -> {
                            String categoryName = limit.getCategory().getName();
                            BigDecimal spent =
                                    transactionRepository
                                            .sumAmountByTypeAndCategoryAndOccurredAtBetween(
                                                    TransactionType.EXPENSE, categoryName, from, to)
                                            .orElse(BigDecimal.ZERO);
                            double percentage =
                                    limit.getAmount().compareTo(BigDecimal.ZERO) == 0
                                            ? 0.0
                                            : spent.multiply(BigDecimal.valueOf(100))
                                                    .divide(
                                                            limit.getAmount(),
                                                            2,
                                                            RoundingMode.HALF_UP)
                                                    .doubleValue();
                            return LimitProgressResponse.builder()
                                    .id(limit.getId())
                                    .categoryName(categoryName)
                                    .limitAmount(limit.getAmount())
                                    .spent(spent)
                                    .percentage(percentage)
                                    .build();
                        })
                .toList();
    }
}
