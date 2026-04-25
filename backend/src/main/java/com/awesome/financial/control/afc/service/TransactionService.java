package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.SummaryResponse;
import com.awesome.financial.control.afc.dto.TransactionResponse;
import com.awesome.financial.control.afc.dto.UpdateTransactionRequest;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.TransactionMapper;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final TransactionMapper transactionMapper;
    private final RecurringTransactionRepository recurringTransactionRepository;

    @Transactional(readOnly = true)
    public List<TransactionResponse> getAllTransactions() {
        return transactionRepository.findAllByOrderByOccurredAtDesc().stream()
                .map(transactionMapper::toResponse)
                .toList();
    }

    @Transactional
    public void deleteTransaction(UUID id) {
        if (!transactionRepository.existsById(id)) {
            throw new ResourceNotFoundException("Transaction", id);
        }
        transactionRepository.deleteById(id);
    }

    @Transactional
    public TransactionResponse updateTransaction(UUID id, UpdateTransactionRequest request) {
        Transaction transaction =
                transactionRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Transaction", id));
        transaction.setDescription(request.description());
        transaction.setAmount(request.amount());
        transaction.setType(request.type());
        transaction.setCategory(request.category());
        transaction.setOccurredAt(request.occurredAt());
        transaction.setPassive(request.isPassive());
        transaction.setInvestmentId(request.investmentId());
        Transaction saved = transactionRepository.save(transaction);
        matchRecurringTransaction(saved);
        return transactionMapper.toResponse(saved);
    }

    @Transactional
    public TransactionResponse createTransaction(
            com.awesome.financial.control.afc.dto.CreateTransactionRequest request) {
        Transaction transaction = new Transaction();
        transaction.setDescription(request.description());
        transaction.setAmount(request.amount());
        transaction.setType(request.type());
        transaction.setCategory(request.category());
        transaction.setOccurredAt(request.occurredAt());
        transaction.setPassive(request.isPassive());
        transaction.setInvestmentId(request.investmentId());
        Transaction saved = transactionRepository.save(transaction);
        return transactionMapper.toResponse(saved);
    }

    @Transactional
    public List<TransactionResponse> createTransactionsBulk(
            List<com.awesome.financial.control.afc.dto.CreateTransactionRequest> requests) {
        List<Transaction> transactions =
                requests.stream()
                        .map(
                                request -> {
                                    Transaction transaction = new Transaction();
                                    transaction.setDescription(request.description());
                                    transaction.setAmount(request.amount());
                                    transaction.setType(request.type());
                                    transaction.setCategory(request.category());
                                    transaction.setOccurredAt(request.occurredAt());
                                    transaction.setPassive(request.isPassive());
                                    transaction.setInvestmentId(request.investmentId());
                                    return transaction;
                                })
                        .toList();

        List<Transaction> saved = transactionRepository.saveAll(transactions);
        saved.forEach(this::matchRecurringTransaction);
        return saved.stream().map(transactionMapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<TransactionResponse> getLastTransactions(int limit) {
        return transactionRepository
                .findAllByOrderByOccurredAtDesc(PageRequest.of(0, limit))
                .stream()
                .map(transactionMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public SummaryResponse getCurrentMonthSummary() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        Instant from = current.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = current.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        BigDecimal totalIncome =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.INCOME, from, to)
                        .orElse(BigDecimal.ZERO);
        BigDecimal totalExpenses =
                transactionRepository
                        .sumAmountByTypeAndOccurredAtBetween(TransactionType.EXPENSE, from, to)
                        .orElse(BigDecimal.ZERO);
        BigDecimal balance = totalIncome.subtract(totalExpenses);

        return SummaryResponse.builder()
                .totalIncome(totalIncome)
                .totalExpenses(totalExpenses)
                .balance(balance)
                .build();
    }

    private void matchRecurringTransaction(Transaction transaction) {
        if (transaction.getCategory() == null) return;

        List<RecurringTransaction> activeRules =
                recurringTransactionRepository.findAllByActiveTrue();
        for (RecurringTransaction rule : activeRules) {
            if (rule.getCategory() != null
                    && rule.getCategory().equalsIgnoreCase(transaction.getCategory())
                    && rule.getType() == transaction.getType()) {

                // Check if amount is similar (within 10%)
                BigDecimal diff = rule.getAmount().subtract(transaction.getAmount()).abs();
                BigDecimal threshold = rule.getAmount().multiply(new BigDecimal("0.1"));

                if (diff.compareTo(threshold) <= 0) {
                    // Update only if this transaction is newer than current lastPaidAt or if
                    // lastPaidAt is null
                    if (rule.getLastPaidAt() == null
                            || transaction.getOccurredAt().isAfter(rule.getLastPaidAt())) {
                        rule.setLastPaidAt(transaction.getOccurredAt());
                        recurringTransactionRepository.save(rule);
                    }
                    break;
                }
            }
        }
    }
}
