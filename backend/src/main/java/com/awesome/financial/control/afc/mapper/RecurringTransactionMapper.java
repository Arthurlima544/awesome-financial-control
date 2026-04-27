package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import org.springframework.stereotype.Component;

@Component
public class RecurringTransactionMapper {

    public RecurringTransaction toEntity(RecurringTransactionRequest request) {
        return RecurringTransaction.builder()
                .description(request.description())
                .amount(request.amount())
                .type(request.type())
                .category(request.category())
                .frequency(request.frequency())
                .nextDueAt(request.nextDueAt())
                .active(request.active())
                .build();
    }

    public void updateEntity(RecurringTransaction entity, RecurringTransactionRequest request) {
        entity.setDescription(request.description());
        entity.setAmount(request.amount());
        entity.setType(request.type());
        entity.setCategory(request.category());
        entity.setFrequency(request.frequency());
        entity.setNextDueAt(request.nextDueAt());
        entity.setActive(request.active());
    }

    public RecurringTransactionResponse toResponse(RecurringTransaction entity) {
        return RecurringTransactionResponse.builder()
                .id(entity.getId())
                .description(entity.getDescription())
                .amount(entity.getAmount())
                .type(entity.getType())
                .category(entity.getCategory())
                .frequency(entity.getFrequency())
                .nextDueAt(entity.getNextDueAt())
                .lastPaidAt(entity.getLastPaidAt())
                .active(entity.isActive())
                .build();
    }

    public Transaction toTransaction(RecurringTransaction recurring) {
        return Transaction.builder()
                .description(recurring.getDescription())
                .amount(recurring.getAmount())
                .type(recurring.getType())
                .category(recurring.getCategory())
                .occurredAt(recurring.getNextDueAt())
                .build();
    }
}
