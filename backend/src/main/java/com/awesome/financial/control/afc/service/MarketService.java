package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.BrapiPrimeRateResponse;
import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import com.awesome.financial.control.afc.dto.MarketBenchmarkDTO;
import com.awesome.financial.control.afc.dto.MarketOpportunityDTO;
import com.awesome.financial.control.afc.model.MarketOpportunity;
import com.awesome.financial.control.afc.repository.MarketOpportunityRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MarketService {

    private final BrapiService brapiService;
    private final MarketOpportunityRepository repository;
    private final java.time.Clock clock;

    private static final List<String> EQUITIES =
            List.of(
                    "VALE3", "PETR4", "BBAS3", "ITUB4", "BBDC4", "ABEV3", "WEGE3", "ITSA4",
                    "SANB11", "EGIE3", "TAEE11", "TRPL4", "VIVT3", "JBSS3", "CSNA3");

    private static final List<String> FIIS =
            List.of(
                    "KNIP11", "HGLG11", "XPLG11", "VISC11", "MALL11", "BTLG11", "MXRF11", "IRDM11",
                    "CPTS11", "RECR11", "HGBS11", "VRTA11");

    private static final ZoneId SAO_PAULO_ZONE = ZoneId.of("America/Sao_Paulo");
    private static final LocalTime MARKET_OPEN = LocalTime.of(10, 0);
    private static final LocalTime MARKET_CLOSE = LocalTime.of(18, 0);

    public List<MarketOpportunityDTO> getOpportunities() {
        List<MarketOpportunity> entities = repository.findAll();
        ZonedDateTime lastUpdated =
                entities.stream()
                        .map(MarketOpportunity::getLastUpdated)
                        .filter(java.util.Objects::nonNull)
                        .max(java.time.ZonedDateTime::compareTo)
                        .orElse(null);

        if (shouldUseCache(entities, lastUpdated)) {
            return entities.stream().map(this::toDTO).toList();
        }

        List<String> allTickers = Stream.concat(EQUITIES.stream(), FIIS.stream()).toList();
        BigDecimal cdiRate = getBenchmarks().cdiRate();
        List<MarketOpportunity> updatedEntities = new ArrayList<>();

        for (String ticker : allTickers) {
            try {
                BrapiQuoteResponse resp = brapiService.fetchQuotes(List.of(ticker + ".SA"));
                if (resp != null && !resp.results().isEmpty()) {
                    updatedEntities.add(toEntity(resp.results().get(0), cdiRate));
                }
            } catch (Exception e) {
                // Skip failed
            }
        }

        if (!updatedEntities.isEmpty()) {
            repository.saveAll(updatedEntities);
            return updatedEntities.stream().map(this::toDTO).toList();
        }

        return entities.stream().map(this::toDTO).toList();
    }

    private boolean shouldUseCache(List<MarketOpportunity> entities, ZonedDateTime lastUpdated) {
        if (entities.isEmpty() || lastUpdated == null) return false;

        ZonedDateTime now = ZonedDateTime.now(clock);
        if (!isMarketOpen()) {
            return true; // Keep using DB data if market is closed
        }

        // Market is open, refresh if more than 1 hour old
        return lastUpdated.plusHours(1).isAfter(now);
    }

    private MarketOpportunity toEntity(
            BrapiQuoteResponse.BrapiQuoteResult res, BigDecimal cdiRate) {
        BigDecimal dy = BigDecimal.ZERO;
        BigDecimal pe = BigDecimal.ZERO;
        BigDecimal pvp = BigDecimal.ZERO;

        if (res.fundamental() != null) {
            dy =
                    res.fundamental().dividendYield() != null
                            ? res.fundamental().dividendYield()
                            : BigDecimal.ZERO;
            pe = res.fundamental().pL();
            pvp = res.fundamental().pVp();
        }

        BigDecimal dyVsCdi = BigDecimal.ZERO;
        if (dy != null && cdiRate.compareTo(BigDecimal.ZERO) > 0) {
            dyVsCdi = dy.divide(cdiRate, 4, RoundingMode.HALF_UP);
        }

        return MarketOpportunity.builder()
                .ticker(res.symbol().replace(".SA", ""))
                .name(res.shortName())
                .type(res.symbol().endsWith("11.SA") ? "FII" : "STOCK")
                .currentPrice(res.regularMarketPrice())
                .changePercent(res.regularMarketChangePercent())
                .logoUrl(res.logourl())
                .sector("") // Brapi quote doesn't always have sector, could be added from
                // fundamentals if available
                .dividendYield(dy)
                .peRatio(pe)
                .pvpRatio(pvp)
                .dyVsCdi(dyVsCdi)
                .lastUpdated(ZonedDateTime.now(clock))
                .build();
    }

    private MarketOpportunityDTO toDTO(MarketOpportunity entity) {
        return new MarketOpportunityDTO(
                entity.getTicker(),
                entity.getName(),
                entity.getCurrentPrice(),
                entity.getChangePercent() != null ? entity.getChangePercent() : BigDecimal.ZERO,
                entity.getDividendYield(),
                "FII".equals(entity.getType()),
                entity.getPeRatio(),
                entity.getSector(),
                entity.getDyVsCdi(),
                entity.getLogoUrl(),
                entity.getLastUpdated());
    }

    public MarketBenchmarkDTO getBenchmarks() {
        // Default values based on current Brazilian market (April 2024)
        BigDecimal defaultSelic = new BigDecimal("10.75");
        BigDecimal defaultCdi = new BigDecimal("10.65");

        try {
            BrapiPrimeRateResponse resp = brapiService.fetchPrimeRates();
            if (resp == null || resp.countryPrimeRate() == null) {
                return new MarketBenchmarkDTO(defaultCdi, defaultSelic);
            }

            BigDecimal selic =
                    resp.countryPrimeRate().stream()
                            .filter(r -> "Selic".equalsIgnoreCase(r.name()))
                            .findFirst()
                            .map(BrapiPrimeRateResponse.PrimeRate::value)
                            .orElse(defaultSelic);

            BigDecimal cdi =
                    resp.countryPrimeRate().stream()
                            .filter(r -> "CDI".equalsIgnoreCase(r.name()))
                            .findFirst()
                            .map(BrapiPrimeRateResponse.PrimeRate::value)
                            .orElse(selic.subtract(new BigDecimal("0.10")));

            return new MarketBenchmarkDTO(cdi, selic);
        } catch (Exception e) {
            return new MarketBenchmarkDTO(defaultCdi, defaultSelic);
        }
    }

    private boolean isMarketOpen() {
        ZonedDateTime now = ZonedDateTime.now(clock);
        DayOfWeek day = now.getDayOfWeek();
        LocalTime time = now.toLocalTime();

        boolean isWeekend = day == DayOfWeek.SATURDAY || day == DayOfWeek.SUNDAY;
        boolean isWorkingHours = !time.isBefore(MARKET_OPEN) && !time.isAfter(MARKET_CLOSE);

        return !isWeekend && isWorkingHours;
    }
}
