package com.awesome.financial.control.afc.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.awesome.financial.control.afc.dto.InvestmentGoalRequest;
import com.awesome.financial.control.afc.service.CalculatorService;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CalculatorController.class)
class CalculatorControllerTest {

    @Autowired private MockMvc mockMvc;

    @Autowired private ObjectMapper objectMapper;

    @MockBean private CalculatorService calculatorService;

    @Test
    void shouldReturnOkForInvestmentGoal() throws Exception {
        InvestmentGoalRequest request =
                new InvestmentGoalRequest(
                        BigDecimal.valueOf(1000),
                        LocalDate.now().plusYears(1),
                        BigDecimal.valueOf(0.1),
                        BigDecimal.ZERO,
                        false);

        mockMvc.perform(
                        post("/api/v1/calculators/investment-goal")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }
}
