package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.RecurringTransactionRequest;
import com.awesome.financial.control.afc.dto.RecurringTransactionResponse;
import com.awesome.financial.control.afc.mapper.RecurringTransactionMapper;
import com.awesome.financial.control.afc.mapper.TransactionMapper;
import com.awesome.financial.control.afc.model.RecurrenceFrequency;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class RecurringTransactionServiceTest {

    @Mock private RecurringTransactionRepository recurringRepository;
    @Mock private TransactionRepository transactionRepository;
    @Mock private RecurringTransactionMapper mapper;

    @InjectMocks private RecurringTransactionService service;

    @Test
    void processPending_oneDueTransaction_createsTransactionAndAdvancesNextDue() {
        Instant yesterday = Instant.now().minus(1, ChronoUnit.DAYS);
        RecurringTransaction rule =
                RecurringTransaction.builder()
                        .description("Coffee")
                        .amount(BigDecimal.valueOf(5))
                        .type(TransactionType.EXPENSE)
                        .category("Food")
                        .frequency(RecurrenceFrequency.DAILY)
                        .nextDueAt(yesterday)
                        .active(true)
                        .build();

        Transaction materialised = Transaction.builder().description("Coffee").build();

        when(recurringRepository.findAllByActiveTrueAndNextDueAtBefore(any()))
                .thenReturn(List.of(rule));
        when(mapper.toTransaction(rule)).thenReturn(materialised);
        when(transactionRepository.save(materialised)).thenReturn(materialised);
        when(recurringRepository.save(any())).thenReturn(rule);

        service.processPending();

        verify(transactionRepository).save(materialised);
        verify(recurringRepository).save(argThat(r -> r.getNextDueAt().isAfter(yesterday)));
    }

    @Test
    void processPending_noDueTransactions_createsNothing() {
        when(recurringRepository.findAllByActiveTrueAndNextDueAtBefore(any()))
                .thenReturn(List.of());

        service.processPending();

        verify(transactionRepository, never()).save(any());
        verify(recurringRepository, never()).save(any());
    }

    @Test
    void matchRecurring_transactionMatchesRule_setsLastPaidAt() {
        Instant now = Instant.now();
        RecurringTransaction rule =
                RecurringTransaction.builder()
                        .description("Rent")
                        .amount(BigDecimal.valueOf(1200))
                        .type(TransactionType.EXPENSE)
                        .category("Housing")
                        .frequency(RecurrenceFrequency.MONTHLY)
                        .nextDueAt(now.plus(30, ChronoUnit.DAYS))
                        .active(true)
                        .build();

        // Use a real TransactionMapper (no dependencies) to test matching end-to-end
        TransactionMapper realMapper = new TransactionMapper();
        TransactionService transactionService =
                new TransactionService(transactionRepository, realMapper, recurringRepository);

        com.awesome.financial.control.afc.dto.CreateTransactionRequest request =
                new com.awesome.financial.control.afc.dto.CreateTransactionRequest(
                        "Monthly Rent",
                        BigDecimal.valueOf(1200),
                        TransactionType.EXPENSE,
                        "Housing",
                        now,
                        false,
                        null);

        Transaction savedTx =
                Transaction.builder()
                        .description("Monthly Rent")
                        .amount(BigDecimal.valueOf(1200))
                        .type(TransactionType.EXPENSE)
                        .category("Housing")
                        .occurredAt(now)
                        .build();

        when(recurringRepository.findAllByActiveTrue()).thenReturn(List.of(rule));
        when(transactionRepository.save(any(Transaction.class))).thenReturn(savedTx);
        when(recurringRepository.save(rule)).thenReturn(rule);

        transactionService.createTransaction(request);

        assertThat(rule.getLastPaidAt()).isNotNull();
        assertThat(rule.getLastPaidAt()).isEqualTo(now);
    }

    @Test
    void toggleActive_setsActiveFalse_whenCalledTwice() {
        UUID id = UUID.randomUUID();
        RecurringTransaction entity =
                RecurringTransaction.builder()
                        .description("Netflix")
                        .amount(BigDecimal.valueOf(45.90))
                        .type(TransactionType.EXPENSE)
                        .frequency(RecurrenceFrequency.MONTHLY)
                        .nextDueAt(Instant.now().plus(5, ChronoUnit.DAYS))
                        .active(true)
                        .build();

        // Use doAnswer so the mock actually mutates the entity like the real mapper would
        doAnswer(
                        inv -> {
                            RecurringTransaction ent = inv.getArgument(0);
                            RecurringTransactionRequest req = inv.getArgument(1);
                            ent.setActive(req.active());
                            return null;
                        })
                .when(mapper)
                .updateEntity(
                        any(RecurringTransaction.class), any(RecurringTransactionRequest.class));

        when(recurringRepository.findById(id)).thenReturn(Optional.of(entity));
        when(recurringRepository.save(entity)).thenReturn(entity);
        when(mapper.toResponse(entity)).thenReturn(RecurringTransactionResponse.builder().build());

        RecurringTransactionRequest deactivate =
                new RecurringTransactionRequest(
                        "Netflix",
                        BigDecimal.valueOf(45.90),
                        TransactionType.EXPENSE,
                        null,
                        RecurrenceFrequency.MONTHLY,
                        Instant.now().plus(5, ChronoUnit.DAYS),
                        false);

        service.update(id, deactivate);
        assertThat(entity.isActive()).isFalse();

        RecurringTransactionRequest reactivate =
                new RecurringTransactionRequest(
                        "Netflix",
                        BigDecimal.valueOf(45.90),
                        TransactionType.EXPENSE,
                        null,
                        RecurrenceFrequency.MONTHLY,
                        Instant.now().plus(5, ChronoUnit.DAYS),
                        true);

        when(recurringRepository.findById(id)).thenReturn(Optional.of(entity));
        service.update(id, reactivate);
        assertThat(entity.isActive()).isTrue();
    }
}
