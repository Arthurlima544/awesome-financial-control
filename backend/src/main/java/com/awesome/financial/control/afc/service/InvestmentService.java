package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.InvestmentRequest;
import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.InvestmentMapper;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InvestmentService {

    private final InvestmentRepository investmentRepository;
    private final InvestmentMapper investmentMapper;

    @Transactional(readOnly = true)
    public List<InvestmentResponse> getAllInvestments() {
        return investmentRepository.findAll().stream().map(investmentMapper::toResponse).toList();
    }

    @Transactional
    public InvestmentResponse createInvestment(InvestmentRequest request) {
        Investment investment = new Investment();
        updateEntityFromRequest(investment, request);
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
