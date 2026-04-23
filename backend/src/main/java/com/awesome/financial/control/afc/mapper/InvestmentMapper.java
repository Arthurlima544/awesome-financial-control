package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.InvestmentResponse;
import com.awesome.financial.control.afc.model.Investment;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Component;

@Component
public class InvestmentMapper {

    public InvestmentResponse toResponse(Investment investment) {
        BigDecimal totalCost = investment.getQuantity().multiply(investment.getAvgCost());
        BigDecimal currentValue = investment.getQuantity().multiply(investment.getCurrentPrice());
        BigDecimal gainLoss = currentValue.subtract(totalCost);

        BigDecimal gainLossPercentage = BigDecimal.ZERO;
        if (totalCost.compareTo(BigDecimal.ZERO) > 0) {
            gainLossPercentage =
                    gainLoss.divide(totalCost, 4, RoundingMode.HALF_UP)
                            .multiply(BigDecimal.valueOf(100));
        }

        return new InvestmentResponse(
                investment.getId(),
                investment.getName(),
                investment.getTicker(),
                investment.getType(),
                investment.getQuantity(),
                investment.getAvgCost(),
                investment.getCurrentPrice(),
                totalCost.setScale(2, RoundingMode.HALF_UP),
                currentValue.setScale(2, RoundingMode.HALF_UP),
                gainLoss.setScale(2, RoundingMode.HALF_UP),
                gainLossPercentage.setScale(2, RoundingMode.HALF_UP));
    }
}
