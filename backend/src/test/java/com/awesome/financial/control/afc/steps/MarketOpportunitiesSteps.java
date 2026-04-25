package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import com.awesome.financial.control.afc.dto.MarketOpportunityDTO;
import com.awesome.financial.control.afc.model.MarketOpportunity;
import com.awesome.financial.control.afc.repository.MarketOpportunityRepository;
import com.awesome.financial.control.afc.service.BrapiService;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

public class MarketOpportunitiesSteps {

    @Autowired private TestRestTemplate restTemplate;
    @Autowired private ScenarioContext context;
    @Autowired private MarketOpportunityRepository repository;
    @Autowired private BrapiService brapiService;
    @Autowired private Clock clock;

    private static final ZoneId SAO_PAULO_ZONE = ZoneId.of("America/Sao_Paulo");

    @Given("the market data cache is empty")
    public void theMarketDataCacheIsEmpty() {
        repository.deleteAll();
        // Set a default time (Monday 11:00 AM)
        setupClock(ZonedDateTime.of(2024, 4, 22, 11, 0, 0, 0, SAO_PAULO_ZONE));
    }

    @Given("the market is closed in Brasilia")
    public void theMarketIsClosedInBrasilia() {
        // Wednesday at 22:00
        ZonedDateTime closedTime = ZonedDateTime.of(2024, 4, 24, 22, 0, 0, 0, SAO_PAULO_ZONE);
        setupClock(closedTime);
    }

    @Given("the market is open in Brasilia")
    public void theMarketIsOpenInBrasilia() {
        // Wednesday at 11:00
        ZonedDateTime openTime = ZonedDateTime.of(2024, 4, 24, 11, 0, 0, 0, SAO_PAULO_ZONE);
        setupClock(openTime);
    }

    @Given("there are market opportunities persisted in the database")
    public void thereAreMarketOpportunitiesPersistedInTheDatabase() {
        MarketOpportunity entity =
                MarketOpportunity.builder()
                        .ticker("PETR4")
                        .name("Petrobras")
                        .currentPrice(BigDecimal.valueOf(35.0))
                        .dividendYield(BigDecimal.valueOf(10.5))
                        .lastUpdated(ZonedDateTime.now(clock))
                        .build();
        repository.save(entity);
    }

    @Given("the persisted market data is older than 1 hour")
    public void thePersistedMarketDataIsOlderThan1Hour() {
        ZonedDateTime staleTime = ZonedDateTime.now(clock).minusMinutes(61);
        MarketOpportunity entity =
                MarketOpportunity.builder()
                        .ticker("VALE3")
                        .name("Vale")
                        .currentPrice(BigDecimal.valueOf(70.0))
                        .dividendYield(BigDecimal.valueOf(8.0))
                        .lastUpdated(staleTime)
                        .build();
        repository.save(entity);
    }

    @When("I request the market opportunities")
    public void iRequestTheMarketOpportunities() {
        ResponseEntity<List<MarketOpportunityDTO>> response =
                restTemplate.exchange(
                        "/api/v1/market/opportunities",
                        HttpMethod.GET,
                        null,
                        new ParameterizedTypeReference<List<MarketOpportunityDTO>>() {});
        context.response = response;
    }

    @Given("the Brapi API returns data")
    public void theBrapiApiReturnsData() {
        BrapiQuoteResponse mockResp =
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
        when(brapiService.fetchQuotes(anyList())).thenReturn(mockResp);
    }

    @Then("the response should contain a list of stocks and FIIs")
    public void theResponseShouldContainAListOfStocksAndFiis() {
        List<MarketOpportunityDTO> body = getResponseBody();
        assertThat(body).isNotEmpty();
    }

    @And("the data should be persisted in the database")
    public void theDataShouldBePersistedInTheDatabase() {
        assertThat(repository.count()).isGreaterThan(0);
    }

    @And("each opportunity should have a {string} timestamp")
    public void eachOpportunityShouldHaveATimestamp(String field) {
        List<MarketOpportunityDTO> body = getResponseBody();
        assertThat(body.get(0).lastUpdated()).isNotNull();
    }

    @Then("the response should contain the persisted data")
    public void theResponseShouldContainThePersistedData() {
        List<MarketOpportunityDTO> body = getResponseBody();
        assertThat(body).isNotEmpty();
        assertThat(body.get(0).ticker()).isEqualTo("PETR4");
    }

    @And("no calls should be made to the Brapi API")
    public void noCallsShouldBeMadeToTheBrapiApi() {
        verify(brapiService, never()).fetchQuotes(anyList());
    }

    @Then("the data should be refreshed from the Brapi API")
    public void theDataShouldBeRefreshedFromTheBrapiApi() {
        verify(brapiService, atLeastOnce()).fetchQuotes(anyList());
    }

    @And("the new data should be saved to the database")
    public void theNewDataShouldBeSavedToTheDatabase() {
        assertThat(repository.count()).isGreaterThan(0);
    }

    private void setupClock(ZonedDateTime dateTime) {
        when(clock.instant()).thenReturn(dateTime.toInstant());
        when(clock.getZone()).thenReturn(dateTime.getZone());
    }

    @SuppressWarnings("unchecked")
    private List<MarketOpportunityDTO> getResponseBody() {
        return (List<MarketOpportunityDTO>) context.response.getBody();
    }
}
