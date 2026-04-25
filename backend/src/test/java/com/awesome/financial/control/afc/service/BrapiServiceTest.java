package com.awesome.financial.control.afc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import com.awesome.financial.control.afc.dto.BrapiPrimeRateResponse;
import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

@SpringBootTest
public class BrapiServiceTest {

    @Autowired private BrapiService brapiService;
    @Autowired private RestTemplate restTemplate;

    private MockRestServiceServer mockServer;

    @BeforeEach
    void setUp() {
        mockServer = MockRestServiceServer.createServer(restTemplate);
    }

    @Test
    void testFetchQuotes() {
        String responseJson =
                """
                {
                    "results": [
                        {
                            "symbol": "PETR4.SA",
                            "shortName": "Petrobras",
                            "regularMarketPrice": 35.0
                        }
                    ]
                }
                """;

        mockServer
                .expect(requestTo(org.hamcrest.Matchers.containsString("/api/quote/PETR4.SA")))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(responseJson, MediaType.APPLICATION_JSON));

        BrapiQuoteResponse response = brapiService.fetchQuotes(List.of("PETR4.SA"));

        assertThat(response).isNotNull();
        assertThat(response.results()).hasSize(1);
        assertThat(response.results().get(0).symbol()).isEqualTo("PETR4.SA");
        mockServer.verify();
    }

    @Test
    void testFetchPrimeRates() {
        String responseJson =
                """
                {
                    "countryPrimeRate": [
                        {
                            "name": "Selic",
                            "value": 10.75
                        }
                    ]
                }
                """;

        mockServer
                .expect(requestTo(org.hamcrest.Matchers.containsString("/api/v2/prime-rate")))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(responseJson, MediaType.APPLICATION_JSON));

        BrapiPrimeRateResponse response = brapiService.fetchPrimeRates();

        assertThat(response).isNotNull();
        assertThat(response.countryPrimeRate()).hasSize(1);
        assertThat(response.countryPrimeRate().get(0).name()).isEqualTo("Selic");
        mockServer.verify();
    }
}
