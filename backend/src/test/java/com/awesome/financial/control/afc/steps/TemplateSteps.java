package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.repository.TemplateRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

public class TemplateSteps {

    @Autowired private TestRestTemplate restTemplate;

    @Autowired private TemplateRepository templateRepository;

    @Autowired private ScenarioContext ctx;

    @After
    public void cleanUp() {
        templateRepository.deleteAll();
    }

    @When("I create a template {string} in category {string} of type {string}")
    @Given("I have created a template {string} in category {string} of type {string}")
    public void iCreateATemplate(String description, String category, String type) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String body =
                String.format(
                        "{\"description\":\"%s\",\"category\":\"%s\",\"type\":\"%s\"}",
                        description, category, type);
        ctx.response =
                restTemplate.postForEntity(
                        "/api/v1/templates", new HttpEntity<>(body, headers), String.class);

        if (ctx.response.getStatusCode().is2xxSuccessful() && ctx.response.getBody() != null) {
            String bodyStr = (String) ctx.response.getBody();
            if (bodyStr.contains("\"id\":\"")) {
                int start = bodyStr.indexOf("\"id\":\"") + 6;
                int end = bodyStr.indexOf("\"", start);
                ctx.lastTemplateId = UUID.fromString(bodyStr.substring(start, end));
            }
        }
    }

    @When("I delete the last created template")
    public void iDeleteTheLastCreatedTemplate() {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/templates/" + ctx.lastTemplateId,
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I delete a template with id {string}")
    public void iDeleteATemplateWithId(String id) {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/templates/" + UUID.fromString(id),
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I list all templates")
    public void iListAllTemplates() {
        ctx.response = restTemplate.getForEntity("/api/v1/templates", String.class);
    }

    @And("there are {int} templates")
    public void thereAreTemplates(int count) {
        ctx.response = restTemplate.getForEntity("/api/v1/templates", String.class);
        long objCount = ((String) ctx.response.getBody()).chars().filter(c -> c == '{').count();
        assertThat(objCount).isEqualTo(count);
    }

    @And("the response contains a list of {int} templates")
    public void theResponseContainsAListOfTemplates(int count) {
        long objCount = ((String) ctx.response.getBody()).chars().filter(c -> c == '{').count();
        assertThat(objCount).isEqualTo(count);
    }

    @And("the response error code is {string}")
    public void theResponseErrorCodeIs(String code) {
        assertThat((String) ctx.response.getBody()).contains("\"code\":\"" + code + "\"");
    }
}
