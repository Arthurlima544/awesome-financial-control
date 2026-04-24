package com.awesome.financial.control.afc.service;

import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import com.awesome.financial.control.afc.model.MarketOpportunity;
import com.awesome.financial.control.afc.repository.MarketOpportunityRepository;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class MarketServiceTest {

    @Mock private BrapiService brapiService;
    @Mock private MarketOpportunityRepository repository;
    @Mock private Clock clock;
    private MarketService marketService;

    private static final ZoneId SAO_PAULO_ZONE = ZoneId.of("America/Sao_Paulo");

    @BeforeEach
    void setup() {
        when(clock.getZone()).thenReturn(SAO_PAULO_ZONE);
        marketService = new MarketService(brapiService, repository, clock);
    }

    private void setTime(ZonedDateTime dateTime) {
        when(clock.instant()).thenReturn(dateTime.toInstant());
        when(clock.getZone()).thenReturn(dateTime.getZone());
    }

    @Test
    void shouldFetchIfCacheEmptyEvenIfMarketClosed() {
        // Wednesday at 22:00 (Closed)
        setTime(ZonedDateTime.of(2024, 4, 24, 22, 0, 0, 0, SAO_PAULO_ZONE));

        when(repository.findAll()).thenReturn(Collections.emptyList());
        BrapiQuoteResponse resp =
                new BrapiQuoteResponse(
                        List.of(
                                new BrapiQuoteResponse.BrapiQuoteResult(
                                        "PETR4.SA",
                                        "Petrobras",
                                        "Petrobras",
                                        "BRL",
                                        BigDecimal.valueOf(35.0),
                                        BigDecimal.ZERO,
                                        BigDecimal.ZERO,
                                        null,
                                        null)),
                        "now");
        when(brapiService.fetchQuotes(anyList())).thenReturn(resp);
        when(brapiService.fetchPrimeRates()).thenReturn(null);

        marketService.getOpportunities();

        verify(brapiService, atLeastOnce()).fetchQuotes(anyList());
        verify(repository).saveAll(anyList());
    }

    @Test
    void shouldNotFetchIfMarketClosedAndHasCache() {
        // Wednesday at 22:00 (Closed)
        ZonedDateTime time = ZonedDateTime.of(2024, 4, 24, 22, 0, 0, 0, SAO_PAULO_ZONE);
        setTime(time);

        MarketOpportunity entity =
                MarketOpportunity.builder().ticker("PETR4").lastUpdated(time).build();
        when(repository.findAll()).thenReturn(List.of(entity));

        // Call - should use DB data because market is closed
        marketService.getOpportunities();

        verify(brapiService, never()).fetchQuotes(anyList());
    }

    @Test
    void shouldRefreshIfMarketOpenAndCacheStale() {
        // Wednesday at 11:00 (Open)
        ZonedDateTime startTime = ZonedDateTime.of(2024, 4, 24, 11, 0, 0, 0, SAO_PAULO_ZONE);
        setTime(startTime);

        // Mock DB returns data older than 1 hour
        MarketOpportunity entity =
                MarketOpportunity.builder()
                        .ticker("PETR4")
                        .lastUpdated(startTime.minusMinutes(61))
                        .build();
        when(repository.findAll()).thenReturn(List.of(entity));

        BrapiQuoteResponse resp =
                new BrapiQuoteResponse(
                        List.of(
                                new BrapiQuoteResponse.BrapiQuoteResult(
                                        "PETR4.SA",
                                        "Petrobras",
                                        "Petrobras",
                                        "BRL",
                                        BigDecimal.valueOf(35.0),
                                        BigDecimal.ZERO,
                                        BigDecimal.ZERO,
                                        null,
                                        null)),
                        "now");
        when(brapiService.fetchQuotes(anyList())).thenReturn(resp);

        marketService.getOpportunities();

        verify(brapiService, atLeastOnce()).fetchQuotes(anyList());
        verify(repository).saveAll(anyList());
    }

    @Test
    void shouldNotRefreshIfMarketOpenAndCacheFresh() {
        // Wednesday at 11:00 (Open)
        ZonedDateTime startTime = ZonedDateTime.of(2024, 4, 24, 11, 0, 0, 0, SAO_PAULO_ZONE);
        setTime(startTime);

        // Mock DB returns fresh data (30 min old)
        MarketOpportunity entity =
                MarketOpportunity.builder()
                        .ticker("PETR4")
                        .lastUpdated(startTime.minusMinutes(30))
                        .build();
        when(repository.findAll()).thenReturn(List.of(entity));

        marketService.getOpportunities();

        verify(brapiService, never()).fetchQuotes(anyList());
    }
}
