package com.awesome.financial.control.afc.repository;

import com.awesome.financial.control.afc.model.Limit;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface LimitRepository extends JpaRepository<Limit, UUID> {

    @Query("SELECT l FROM Limit l JOIN FETCH l.category")
    List<Limit> findAllWithCategory();

    boolean existsByCategoryId(UUID categoryId);
}
