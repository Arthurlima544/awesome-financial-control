package com.awesome.financial.control.afc.model;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor
@SuperBuilder
public class Transaction extends AbstractTransaction {

    @Column(name = "occurred_at", nullable = false)
    private Instant occurredAt;
}
