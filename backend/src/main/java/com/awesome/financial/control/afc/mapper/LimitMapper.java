package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.LimitProgressResponse;
import com.awesome.financial.control.afc.dto.LimitResponse;
import com.awesome.financial.control.afc.model.Limit;
import java.math.BigDecimal;
import org.springframework.stereotype.Component;

@Component
public class LimitMapper {

    public LimitResponse toResponse(Limit limit) {
        return LimitResponse.builder()
                .id(limit.getId())
                .categoryName(limit.getCategory().getName())
                .amount(limit.getAmount())
                .createdAt(limit.getCreatedAt())
                .build();
    }

    public LimitProgressResponse toProgressResponse(
            Limit limit, BigDecimal spent, double percentage) {
        return LimitProgressResponse.builder()
                .id(limit.getId())
                .categoryName(limit.getCategory().getName())
                .limitAmount(limit.getAmount())
                .spent(spent)
                .percentage(percentage)
                .build();
    }
}
