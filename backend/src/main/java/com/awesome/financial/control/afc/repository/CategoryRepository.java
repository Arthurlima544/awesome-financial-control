package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Category;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, UUID> {}
