package com.awesome.financial.control.afc.model;

import com.awesome.financial.control.afc.utils.StringNormalizer;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "categories")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(name = "normalized_name")
    private String normalizedName;

    @Builder.Default
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @PrePersist
    @PreUpdate
    protected void normalizeFields() {
        this.normalizedName = StringNormalizer.normalize(this.name);
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}
