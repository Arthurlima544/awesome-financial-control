package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.MarketOpportunity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MarketOpportunityRepository extends JpaRepository<MarketOpportunity, String> {}
