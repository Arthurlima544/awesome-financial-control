package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.InvestmentDashboardResponse;
import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.exception.ConflictException;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.InvestmentMapper;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.InvestmentType;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InvestmentService {

    private final InvestmentRepository investmentRepository;
    private final InvestmentMapper investmentMapper;
    private final TransactionRepository transactionRepository;
    private final RecurringTransactionRepository recurringTransactionRepository;

    @Transactional(readOnly = true)
    public List<InvestmentResponse> getAllInvestments() {
        return investmentRepository.findAll().stream().map(investmentMapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public InvestmentDashboardResponse getDashboardData() {
        List<Investment> investments = investmentRepository.findAll();

        BigDecimal totalInvested = BigDecimal.ZERO;
        BigDecimal totalCurrentValue = BigDecimal.ZERO;
        Map<InvestmentType, BigDecimal> allocationByType = new EnumMap<>(InvestmentType.class);
        List<InvestmentDashboardResponse.AssetPerformance> performances = new ArrayList<>();

        for (Investment inv : investments) {
            BigDecimal invested = inv.getAvgCost().multiply(inv.getQuantity());
            BigDecimal current = inv.getCurrentPrice().multiply(inv.getQuantity());

            totalInvested = totalInvested.add(invested);
            totalCurrentValue = totalCurrentValue.add(current);

            allocationByType.merge(inv.getType(), current, BigDecimal::add);

            BigDecimal profitLoss = current.subtract(invested);
            double percentage =
                    invested.compareTo(BigDecimal.ZERO) > 0
                            ? profitLoss.divide(invested, 4, RoundingMode.HALF_UP).doubleValue()
                                    * 100
                            : 0;

            performances.add(
                    new InvestmentDashboardResponse.AssetPerformance(
                            inv.getTicker(),
                            inv.getName(),
                            profitLoss.setScale(2, RoundingMode.HALF_UP),
                            percentage));
        }

        BigDecimal totalProfitLoss = totalCurrentValue.subtract(totalInvested);
        double totalPercentage =
                totalInvested.compareTo(BigDecimal.ZERO) > 0
                        ? totalProfitLoss
                                        .divide(totalInvested, 4, RoundingMode.HALF_UP)
                                        .doubleValue()
                                * 100
                        : 0;

        return new InvestmentDashboardResponse(
                totalInvested.setScale(2, RoundingMode.HALF_UP),
                totalCurrentValue.setScale(2, RoundingMode.HALF_UP),
                totalProfitLoss.setScale(2, RoundingMode.HALF_UP),
                totalPercentage,
                allocationByType,
                performances.stream()
                        .sorted((a, b) -> Double.compare(b.percentage(), a.percentage()))
                        .toList());
    }

    @Transactional
    public InvestmentResponse createInvestment(InvestmentRequest request) {
        Investment investment =
                Investment.builder()
                        .name(request.name())
                        .ticker(request.ticker())
                        .type(request.type())
                        .quantity(request.quantity())
                        .avgCost(request.avgCost())
                        .currentPrice(request.currentPrice())
                        .build();
        Investment saved = investmentRepository.save(investment);
        return investmentMapper.toResponse(saved);
    }

    @Transactional
    public InvestmentResponse updateInvestment(UUID id, InvestmentRequest request) {
        Investment investment =
                investmentRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Investment", id));
        updateEntityFromRequest(investment, request);
        Investment saved = investmentRepository.save(investment);
        return investmentMapper.toResponse(saved);
    }

    @Transactional
    public void deleteInvestment(UUID id) {
        if (!investmentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Investment", id);
        }
        if (transactionRepository.existsByInvestmentId(id)
                || recurringTransactionRepository.existsByInvestmentId(id)) {
            throw new ConflictException(
                    "Investimento possui transações ou recorrências associadas");
        }
        investmentRepository.deleteById(id);
    }

    @Transactional
    public InvestmentResponse updatePrice(UUID id, BigDecimal currentPrice) {
        Investment investment =
                investmentRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Investment", id));
        investment.setCurrentPrice(currentPrice);
        Investment saved = investmentRepository.save(investment);
        return investmentMapper.toResponse(saved);
    }

    private void updateEntityFromRequest(Investment investment, InvestmentRequest request) {
        investment.setName(request.name());
        investment.setTicker(request.ticker());
        investment.setType(request.type());
        investment.setQuantity(request.quantity());
        investment.setAvgCost(request.avgCost());
        investment.setCurrentPrice(request.currentPrice());
    }
}
