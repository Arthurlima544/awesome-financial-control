package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Template;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TemplateRepository extends JpaRepository<Template, UUID> {
    List<Template> findAllByOrderByCreatedAtDesc();
}
