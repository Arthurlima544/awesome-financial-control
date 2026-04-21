package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import org.springframework.stereotype.Component;

@Component
public class RecurringTransactionMapper {

    public RecurringTransaction toEntity(RecurringTransactionRequest request) {
        RecurringTransaction entity = new RecurringTransaction();
        updateEntity(entity, request);
        return entity;
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
                .active(entity.isActive())
                .build();
    }

    public Transaction toTransaction(RecurringTransaction recurring) {
        Transaction t = new Transaction();
        t.setDescription(recurring.getDescription());
        t.setAmount(recurring.getAmount());
        t.setType(recurring.getType());
        t.setCategory(recurring.getCategory());
        t.setOccurredAt(recurring.getNextDueAt()); // The due date becomes the occurred date
        return t;
    }
}
