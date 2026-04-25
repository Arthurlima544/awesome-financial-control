package com.awesome.financial.control.afc.controller;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.awesome.financial.control.afc.dto.MarketBenchmarkDTO;
import com.awesome.financial.control.afc.service.MarketService;
import java.math.BigDecimal;
import java.util.Collections;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(MarketController.class)
public class MarketControllerUnitTest {

    @Autowired private MockMvc mockMvc;

    @MockitoBean private MarketService marketService;

    @Test
    void testGetOpportunities() throws Exception {
        when(marketService.getOpportunities()).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/v1/market/opportunities")).andExpect(status().isOk());
    }

    @Test
    void testGetBenchmarks() throws Exception {
        when(marketService.getBenchmarks())
                .thenReturn(new MarketBenchmarkDTO(BigDecimal.TEN, BigDecimal.TEN));

        mockMvc.perform(get("/api/v1/market/benchmarks")).andExpect(status().isOk());
    }
}
