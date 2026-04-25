package com.awesome.financial.control.afc.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "market_opportunities")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MarketOpportunity {

    @Id private String ticker;

    private String name;
    private String type;

    @Column(name = "current_price")
    private BigDecimal currentPrice;

    @Column(name = "dividend_yield")
    private BigDecimal dividendYield;

    @Column(name = "pe_ratio")
    private BigDecimal peRatio;

    @Column(name = "pvp_ratio")
    private BigDecimal pvpRatio;

    @Column(name = "dy_vs_cdi")
    private BigDecimal dyVsCdi;

    @Column(name = "last_updated")
    private ZonedDateTime lastUpdated;
}
