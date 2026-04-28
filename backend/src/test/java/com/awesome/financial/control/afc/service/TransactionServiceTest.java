package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.CreateTransactionRequest;
import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.TransactionMapper;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageRequest;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock private TransactionRepository transactionRepository;
    @Mock private TransactionMapper transactionMapper;
    @Mock private RecurringTransactionRepository recurringTransactionRepository;

    @InjectMocks private TransactionService transactionService;

    @Test
    void createTransaction_validRequest_savesAndReturnsResponse() {
        CreateTransactionRequest request =
                new CreateTransactionRequest(
                        "Lunch",
                        BigDecimal.valueOf(45.50),
                        TransactionType.EXPENSE,
                        null,
                        Instant.now(),
                        false,
                        null);
        Transaction saved = Transaction.builder().description("Lunch").build();
        TransactionResponse expected =
                TransactionResponse.builder()
                        .id(UUID.randomUUID())
                        .description("Lunch")
                        .amount(BigDecimal.valueOf(45.50))
                        .type(TransactionType.EXPENSE)
                        .build();

        when(transactionRepository.save(any(Transaction.class))).thenReturn(saved);
        when(transactionMapper.toResponse(saved)).thenReturn(expected);

        TransactionResponse result = transactionService.createTransaction(request);

        assertThat(result).isEqualTo(expected);
        verify(transactionRepository).save(any(Transaction.class));
    }

    @Test
    void createTransactionsBulk_threeItems_savesAll() {
        List<CreateTransactionRequest> requests =
                List.of(
                        new CreateTransactionRequest(
                                "Salary",
                                BigDecimal.valueOf(5000),
                                TransactionType.INCOME,
                                null,
                                Instant.now(),
                                false,
                                null),
                        new CreateTransactionRequest(
                                "Rent",
                                BigDecimal.valueOf(1200),
                                TransactionType.EXPENSE,
                                null,
                                Instant.now(),
                                false,
                                null),
                        new CreateTransactionRequest(
                                "Groceries",
                                BigDecimal.valueOf(300),
                                TransactionType.EXPENSE,
                                null,
                                Instant.now(),
                                false,
                                null));

        List<Transaction> savedList =
                List.of(
                        Transaction.builder().description("Salary").build(),
                        Transaction.builder().description("Rent").build(),
                        Transaction.builder().description("Groceries").build());

        when(transactionRepository.saveAll(any())).thenReturn(savedList);
        when(transactionMapper.toResponse(any(Transaction.class)))
                .thenReturn(TransactionResponse.builder().build());

        List<TransactionResponse> result = transactionService.createTransactionsBulk(requests);

        assertThat(result).hasSize(3);
        verify(transactionRepository).saveAll(any());
    }

    @Test
    void deleteTransaction_notFound_throwsResourceNotFoundException() {
        UUID id = UUID.randomUUID();
        when(transactionRepository.existsById(id)).thenReturn(false);

        assertThatThrownBy(() -> transactionService.deleteTransaction(id))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(transactionRepository, never()).deleteById(id);
    }

    @Test
    void getLastTransactions_limitParam_returnsAtMostNRecords() {
        List<Transaction> dbResult =
                List.of(
                        Transaction.builder().description("A").build(),
                        Transaction.builder().description("B").build());

        when(transactionRepository.findAllByOrderByOccurredAtDesc(PageRequest.of(0, 2)))
                .thenReturn(dbResult);
        when(transactionMapper.toResponse(any(Transaction.class)))
                .thenReturn(TransactionResponse.builder().build());

        List<TransactionResponse> result = transactionService.getLastTransactions(2);

        assertThat(result).hasSize(2);
        verify(transactionRepository).findAllByOrderByOccurredAtDesc(PageRequest.of(0, 2));
    }
}
