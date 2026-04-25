package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Feedback;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeedbackRepository extends JpaRepository<Feedback, UUID> {}
