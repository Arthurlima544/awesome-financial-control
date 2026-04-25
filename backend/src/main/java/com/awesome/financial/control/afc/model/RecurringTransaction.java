package com.awesome.financial.control.afc.model;

import jakarta.persistence.*;
import java.time.Instant;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "recurring_transactions")
@Getter
@Setter
@NoArgsConstructor
public class RecurringTransaction extends AbstractTransaction {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RecurrenceFrequency frequency;

    @Column(name = "next_due_at", nullable = false)
    private Instant nextDueAt;

    @Column(name = "last_paid_at")
    private Instant lastPaidAt;

    @Column(nullable = false)
    private boolean active = true;
}
