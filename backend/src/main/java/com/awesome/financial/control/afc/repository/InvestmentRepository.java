package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Investment;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface InvestmentRepository extends JpaRepository<Investment, UUID> {
    Optional<Investment> findByTicker(String ticker);
}
