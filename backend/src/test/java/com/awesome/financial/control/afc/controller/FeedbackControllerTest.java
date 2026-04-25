package com.awesome.financial.control.afc.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.awesome.financial.control.afc.dto.FeedbackRequest;
import com.awesome.financial.control.afc.dto.FeedbackResponse;
import com.awesome.financial.control.afc.service.FeedbackService;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(FeedbackController.class)
class FeedbackControllerTest {

    @Autowired private MockMvc mockMvc;

    @Autowired private ObjectMapper objectMapper;

    @MockBean private FeedbackService feedbackService;

    @Test
    void shouldReturnCreatedWhenFeedbackIsSubmitted() throws Exception {
        UUID userId = UUID.randomUUID();
        FeedbackRequest request = new FeedbackRequest(userId, 5, "Great app!", "1.0.0", "iOS");

        FeedbackResponse response =
                new FeedbackResponse(
                        UUID.randomUUID(), userId, 5, "Great app!", "1.0.0", "iOS", Instant.now());

        when(feedbackService.submitFeedback(any(FeedbackRequest.class))).thenReturn(response);

        mockMvc.perform(
                        post("/api/v1/feedbacks")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.message").value("Great app!"));
    }

    @Test
    void shouldReturnBadRequestWhenRatingIsInvalid() throws Exception {
        FeedbackRequest request =
                new FeedbackRequest(
                        UUID.randomUUID(),
                        6, // Invalid rating (> 5)
                        "Too high rating",
                        "1.0.0",
                        "iOS");

        mockMvc.perform(
                        post("/api/v1/feedbacks")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());
    }
}
