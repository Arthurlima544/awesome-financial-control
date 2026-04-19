package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TransactionRepository extends JpaRepository<Transaction, UUID> {

    List<Transaction> findAllByOrderByOccurredAtDesc(Pageable pageable);

    @Query(
            "SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.type = :type AND t.occurredAt >= :from AND t.occurredAt < :to")
    java.math.BigDecimal sumAmountByTypeAndOccurredAtBetween(
            @Param("type") TransactionType type,
            @Param("from") Instant from,
            @Param("to") Instant to);
}
