package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.BrapiPrimeRateResponse;
import com.awesome.financial.control.afc.dto.BrapiQuoteResponse;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class BrapiService {

    private final RestTemplate restTemplate;

    @Value("${brapi.token:}")
    private String token;

    private static final String BASE_URL = "https://brapi.dev/api";

    @Cacheable("market-quotes")
    public BrapiQuoteResponse fetchQuotes(List<String> tickers) {
        log.info(
                "Fetching market quotes from Brapi for {} symbols. Token: {}",
                tickers.size(),
                maskToken(token));

        String symbols = String.join(",", tickers);
        String url = BASE_URL + "/quote/" + symbols + "?fundamental=true";

        return executeGet(url, BrapiQuoteResponse.class);
    }

    @Cacheable("benchmarks")
    public BrapiPrimeRateResponse fetchPrimeRates() {
        log.info("Fetching prime rates from Brapi. Token: {}", maskToken(token));
        String url = BASE_URL + "/v2/prime-rate?country=brazil";

        return executeGet(url, BrapiPrimeRateResponse.class);
    }

    private <T> T executeGet(String url, Class<T> responseType) {
        try {
            org.springframework.http.HttpHeaders headers =
                    new org.springframework.http.HttpHeaders();
            if (token != null && !token.isEmpty()) {
                headers.setBearerAuth(token);
            }

            org.springframework.http.HttpEntity<String> entity =
                    new org.springframework.http.HttpEntity<>(headers);
            return restTemplate
                    .exchange(url, org.springframework.http.HttpMethod.GET, entity, responseType)
                    .getBody();
        } catch (Exception e) {
            log.error("Error calling Brapi: {}", e.getMessage());
            return null;
        }
    }

    private String maskToken(String t) {
        if (t == null || t.length() < 4) return "****";
        return t.substring(0, 4) + "..." + t.substring(t.length() - 2);
    }
}
