package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.dto.FeedbackRequest;
import io.cucumber.java.en.And;
import io.cucumber.java.en.When;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.web.client.TestRestTemplate;

@RequiredArgsConstructor
public class FeedbackSteps {

    private final TestRestTemplate restTemplate;
    private final ScenarioContext context;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @When("I submit feedback with:")
    public void iSubmitFeedbackWith(Map<String, String> data) {
        FeedbackRequest request =
                new FeedbackRequest(
                        UUID.randomUUID(),
                        data.containsKey("rating") ? Integer.parseInt(data.get("rating")) : 0,
                        data.get("message"),
                        data.get("appVersion"),
                        data.get("platform"));

        context.response = restTemplate.postForEntity("/api/v1/feedbacks", request, String.class);
    }

    @And("the feedback response should contain:")
    public void theFeedbackResponseShouldContain(Map<String, String> data) throws Exception {
        String body = (String) context.response.getBody();
        Map<String, Object> json = objectMapper.readValue(body, Map.class);

        if (data.containsKey("rating")) {
            assertThat(json.get("rating")).isEqualTo(Integer.parseInt(data.get("rating")));
        }
        if (data.containsKey("message")) {
            assertThat(json.get("message")).isEqualTo(data.get("message"));
        }
        if (data.containsKey("appVersion")) {
            assertThat(json.get("appVersion")).isEqualTo(data.get("appVersion"));
        }
        if (data.containsKey("platform")) {
            assertThat(json.get("platform")).isEqualTo(data.get("platform"));
        }

        assertThat(json.get("id")).isNotNull();
        assertThat(json.get("createdAt")).isNotNull();
    }
}
