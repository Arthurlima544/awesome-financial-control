package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

import com.awesome.financial.control.afc.dto.BrapiPrimeRateResponse;
import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import com.awesome.financial.control.afc.dto.MarketOpportunityDTO;
import com.awesome.financial.control.afc.repository.MarketOpportunityRepository;
import java.math.BigDecimal;
import java.time.*;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class MarketServiceEdgeCasesTest {

    @Mock private BrapiService brapiService;
    @Mock private MarketOpportunityRepository repository;
    private Clock clock;
    private MarketService marketService;

    private static final ZoneId SAO_PAULO_ZONE = ZoneId.of("America/Sao_Paulo");

    @BeforeEach
    void setUp() {
        // Clock will be set per test
    }

    private void initService(ZonedDateTime dateTime) {
        clock = Clock.fixed(dateTime.toInstant(), dateTime.getZone());
        marketService = new MarketService(brapiService, repository, clock);
    }

    @Test
    void testIsMarketOpenOnWeekend() {
        // Saturday 11 AM
        initService(ZonedDateTime.of(2024, 4, 20, 11, 0, 0, 0, SAO_PAULO_ZONE));

        when(repository.findAll()).thenReturn(Collections.emptyList());
        // If cache is empty and market is closed, it should try to fetch but might return empty if
        // API returns null
        // But the key here is hitting the weekend branch in isMarketOpen
        List<MarketOpportunityDTO> result = marketService.getOpportunities();
        assertThat(result).isEmpty();
    }

    @Test
    void testIsMarketOpenAtBoundary() {
        // Exactly 10:00 AM (Open)
        initService(ZonedDateTime.of(2024, 4, 22, 10, 0, 0, 0, SAO_PAULO_ZONE));
        when(repository.findAll()).thenReturn(Collections.emptyList());
        when(brapiService.fetchPrimeRates()).thenReturn(null); // hits fallback in getBenchmarks

        marketService.getOpportunities();
        verify(brapiService, atLeastOnce()).fetchQuotes(anyList());
    }

    @Test
    void testToEntityWithNullFundamental() {
        initService(ZonedDateTime.of(2024, 4, 22, 11, 0, 0, 0, SAO_PAULO_ZONE));

        BrapiQuoteResponse.BrapiQuoteResult result =
                new BrapiQuoteResponse.BrapiQuoteResult(
                        "PETR4.SA",
                        "Petrobras",
                        "Petrobras",
                        "BRL",
                        BigDecimal.valueOf(35.0),
                        BigDecimal.ZERO,
                        BigDecimal.ZERO,
                        null,
                        null // fundamental is null
                        );

        when(repository.findAll()).thenReturn(Collections.emptyList());
        when(brapiService.fetchPrimeRates()).thenReturn(null);
        when(brapiService.fetchQuotes(anyList()))
                .thenReturn(new BrapiQuoteResponse(List.of(result), "now"));

        List<MarketOpportunityDTO> opportunities = marketService.getOpportunities();
        assertThat(opportunities).isNotEmpty();
        assertThat(opportunities.get(0).dividendYield()).isEqualTo(BigDecimal.ZERO);
    }

    @Test
    void testToEntityForFII() {
        initService(ZonedDateTime.of(2024, 4, 22, 11, 0, 0, 0, SAO_PAULO_ZONE));

        BrapiQuoteResponse.BrapiQuoteResult result =
                new BrapiQuoteResponse.BrapiQuoteResult(
                        "MXRF11.SA",
                        "MXRF11",
                        "MXRF11",
                        "BRL",
                        BigDecimal.valueOf(10.0),
                        BigDecimal.ZERO,
                        BigDecimal.ZERO,
                        null,
                        null);

        when(repository.findAll()).thenReturn(Collections.emptyList());
        when(brapiService.fetchPrimeRates()).thenReturn(null);
        when(brapiService.fetchQuotes(anyList()))
                .thenReturn(new BrapiQuoteResponse(List.of(result), "now"));

        List<MarketOpportunityDTO> opportunities = marketService.getOpportunities();
        assertThat(opportunities.get(0).isFii()).isTrue();
    }

    @Test
    void testGetBenchmarksWithEmptyRates() {
        initService(ZonedDateTime.of(2024, 4, 22, 11, 0, 0, 0, SAO_PAULO_ZONE));

        BrapiPrimeRateResponse emptyResp = new BrapiPrimeRateResponse(Collections.emptyList());
        when(brapiService.fetchPrimeRates()).thenReturn(emptyResp);

        var benchmarks = marketService.getBenchmarks();
        assertThat(benchmarks.selicRate()).isEqualTo(new BigDecimal("10.75")); // fallback
        assertThat(benchmarks.cdiRate())
                .isEqualTo(new BigDecimal("10.65")); // fallback (selic - 0.10)
    }

    @Test
    void testGetOpportunitiesWhenApiFailsForAll() {
        initService(ZonedDateTime.of(2024, 4, 22, 11, 0, 0, 0, SAO_PAULO_ZONE));

        when(repository.findAll()).thenReturn(Collections.emptyList());
        when(brapiService.fetchQuotes(anyList())).thenThrow(new RuntimeException("API Down"));

        List<MarketOpportunityDTO> result = marketService.getOpportunities();
        assertThat(result).isEmpty();
    }
}
