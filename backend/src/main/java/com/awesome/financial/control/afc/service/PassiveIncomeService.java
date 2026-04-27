package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.PassiveIncomeDashboardResponse;
import com.awesome.financial.control.afc.mapper.PassiveIncomeMapper;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PassiveIncomeService {

    private final TransactionRepository transactionRepository;
    private final InvestmentRepository investmentRepository;
    private final PassiveIncomeMapper passiveIncomeMapper;

    @Transactional(readOnly = true)
    public PassiveIncomeDashboardResponse getDashboardData() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        Instant from = current.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = current.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        BigDecimal passiveIncome =
                transactionRepository
                        .sumPassiveIncomeByOccurredAtBetween(from, to)
                        .orElse(BigDecimal.ZERO);

        BigDecimal expenses =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.EXPENSE, from, to)
                        .orElse(BigDecimal.ZERO);

        double freedomIndex =
                expenses.compareTo(BigDecimal.ZERO) > 0
                        ? passiveIncome.divide(expenses, 4, RoundingMode.HALF_UP).doubleValue()
                                * 100
                        : (passiveIncome.compareTo(BigDecimal.ZERO) > 0 ? 100.0 : 0.0);

        Map<String, BigDecimal> incomeByInvestment = new HashMap<>();
        List<Object[]> grouped =
                transactionRepository.sumPassiveIncomeGroupByInvestmentAndOccurredAtBetween(
                        from, to);

        for (Object[] row : grouped) {
            UUID investmentId = (UUID) row[0];
            BigDecimal amount = (BigDecimal) row[1];
            String label = "Outros";
            if (investmentId != null) {
                label =
                        investmentRepository
                                .findById(investmentId)
                                .map(
                                        inv -> {
                                            if (inv.getTicker() != null
                                                    && !inv.getTicker().isBlank()) {
                                                return inv.getTicker();
                                            }
                                            return inv.getName();
                                        })
                                .orElse("Desconhecido");
            }
            incomeByInvestment.put(label, amount);
        }

        List<PassiveIncomeDashboardResponse.MonthlyPassiveIncome> progression = new ArrayList<>();
        for (int i = 5; i >= 0; i--) {
            YearMonth ym = current.minusMonths(i);
            Instant f = ym.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
            Instant t = ym.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
            BigDecimal amount =
                    transactionRepository
                            .sumPassiveIncomeByOccurredAtBetween(f, t)
                            .orElse(BigDecimal.ZERO);
            progression.add(
                    new PassiveIncomeDashboardResponse.MonthlyPassiveIncome(ym.toString(), amount));
        }

        return passiveIncomeMapper.toDashboardResponse(
                passiveIncome, expenses, freedomIndex, incomeByInvestment, progression);
    }
}
