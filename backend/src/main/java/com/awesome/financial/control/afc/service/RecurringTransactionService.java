package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.RecurringTransactionMapper;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class RecurringTransactionService {

    private final RecurringTransactionRepository recurringRepository;
    private final TransactionRepository transactionRepository;
    private final RecurringTransactionMapper mapper;

    public List<RecurringTransactionResponse> findAll() {
        return recurringRepository.findAll().stream().map(mapper::toResponse).toList();
    }

    public RecurringTransactionResponse create(RecurringTransactionRequest request) {
        RecurringTransaction entity = mapper.toEntity(request);
        return mapper.toResponse(recurringRepository.save(entity));
    }

    public RecurringTransactionResponse update(UUID id, RecurringTransactionRequest request) {
        RecurringTransaction entity =
                recurringRepository
                        .findById(id)
                        .orElseThrow(
                                () ->
                                        new ResourceNotFoundException(
                                                "Recurring transaction not found"));
        mapper.updateEntity(entity, request);
        return mapper.toResponse(recurringRepository.save(entity));
    }

    public void delete(UUID id) {
        if (!recurringRepository.existsById(id)) {
            throw new ResourceNotFoundException("RecurringTransaction", id);
        }
        recurringRepository.deleteById(id);
    }

    @Transactional
    public void processPending() {
        Instant now = Instant.now();
        List<RecurringTransaction> pending =
                recurringRepository.findAllByActiveTrueAndNextDueAtBefore(now);
        log.info("Processing {} pending recurring transactions", pending.size());

        for (RecurringTransaction recurring : pending) {
            Transaction transaction = mapper.toTransaction(recurring);
            transactionRepository.save(transaction);

            // Update next due date
            recurring.setNextDueAt(
                    calculateNextDueAt(recurring.getNextDueAt(), recurring.getFrequency()));
            recurringRepository.save(recurring);
        }
    }

    private Instant calculateNextDueAt(
            Instant currentDue,
            com.awesome.financial.control.afc.model.RecurrenceFrequency frequency) {
        ZonedDateTime zdt = currentDue.atZone(ZoneId.systemDefault());
        zdt =
                switch (frequency) {
                    case DAILY -> zdt.plusDays(1);
                    case WEEKLY -> zdt.plusWeeks(1);
                    case MONTHLY -> zdt.plusMonths(1);
                };
        return zdt.toInstant();
    }
}
