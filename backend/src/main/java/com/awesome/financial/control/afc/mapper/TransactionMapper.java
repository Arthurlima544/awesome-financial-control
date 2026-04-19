package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.model.Transaction;
import org.springframework.stereotype.Component;

@Component
public class TransactionMapper {

    public TransactionResponse toResponse(Transaction transaction) {
        return TransactionResponse.builder()
                .id(transaction.getId())
                .description(transaction.getDescription())
                .amount(transaction.getAmount())
                .type(transaction.getType())
                .category(transaction.getCategory())
                .occurredAt(transaction.getOccurredAt())
                .build();
    }
}
