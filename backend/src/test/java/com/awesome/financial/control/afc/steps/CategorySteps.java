package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.repository.CategoryRepository;
import io.cucumber.java.en.And;
import io.cucumber.java.en.When;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

public class CategorySteps {

    @Autowired private TestRestTemplate restTemplate;

    @Autowired private CategoryRepository categoryRepository;

    @Autowired private ScenarioContext ctx;

    @When("I request all categories")
    public void iRequestAllCategories() {
        ctx.response = restTemplate.getForEntity("/api/v1/categories", String.class);
    }

    @When("I delete the last created category")
    public void iDeleteTheLastCreatedCategory() {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/categories/" + ctx.lastCategoryId,
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I delete category with id {string}")
    public void iDeleteCategoryWithId(String id) {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/categories/" + UUID.fromString(id),
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I update the last created category name to {string}")
    public void iUpdateTheLastCreatedCategoryNameTo(String name) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>("{\"name\":\"" + name + "\"}", headers);
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/categories/" + ctx.lastCategoryId,
                        HttpMethod.PUT,
                        entity,
                        String.class);
    }

    @When("I update category with id {string} name to {string}")
    public void iUpdateCategoryWithIdNameTo(String id, String name) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>("{\"name\":\"" + name + "\"}", headers);
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/categories/" + UUID.fromString(id),
                        HttpMethod.PUT,
                        entity,
                        String.class);
    }

    @And("the category list is empty")
    public void theCategoryListIsEmpty() {
        assertThat(ctx.response.getBody()).isEqualTo("[]");
    }

    @And("the category list has {int} items")
    public void theCategoryListHasItems(int count) {
        long objCount = ctx.response.getBody().chars().filter(c -> c == '{').count();
        assertThat(objCount).isEqualTo(count);
    }

    @And("the category no longer exists")
    public void theCategoryNoLongerExists() {
        assertThat(categoryRepository.existsById(ctx.lastCategoryId)).isFalse();
    }

    @And("the category name is {string}")
    public void theCategoryNameIs(String name) {
        assertThat(ctx.response.getBody()).contains("\"name\":\"" + name + "\"");
    }
}
