package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.RecurringTransaction;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecurringTransactionRepository extends JpaRepository<RecurringTransaction, UUID> {
    List<RecurringTransaction> findAllByActiveTrueAndNextDueAtBefore(Instant now);

    List<RecurringTransaction> findAllByActiveTrue();

    boolean existsByInvestmentId(UUID investmentId);
}
