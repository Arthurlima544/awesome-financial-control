package com.awesome.financial.control.afc.steps;

import static org.assertj.core.api.Assertions.assertThat;

import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import io.cucumber.java.After;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

public class LimitSteps {

    @Autowired private TestRestTemplate restTemplate;

    @Autowired private CategoryRepository categoryRepository;

    @Autowired private LimitRepository limitRepository;

    @Autowired private TransactionRepository transactionRepository;

    @Autowired private ScenarioContext ctx;

    @After
    public void cleanUp() {
        transactionRepository.deleteAll();
        limitRepository.deleteAll();
        categoryRepository.deleteAll();
    }

    @Given("a category named {string}")
    public void aCategoryNamed(String name) {
        Category category = new Category();
        category.setName(name);
        ctx.lastCategoryId = categoryRepository.save(category).getId();
    }

    @Given("a spending limit of {bigdecimal} for category {string}")
    public void aSpendingLimitForCategory(BigDecimal amount, String categoryName) {
        Category category =
                categoryRepository.findAll().stream()
                        .filter(c -> c.getName().equals(categoryName))
                        .findFirst()
                        .orElseThrow(
                                () ->
                                        new IllegalStateException(
                                                "Category not found: " + categoryName));
        Limit limit = new Limit();
        limit.setCategory(category);
        limit.setAmount(amount);
        ctx.lastLimitId = limitRepository.save(limit).getId();
    }

    @Given(
            "a transaction with description {string} amount {bigdecimal} type {word} in category {string} occurred today")
    public void aTransactionInCategoryOccurredToday(
            String description, BigDecimal amount, String type, String category) {
        Transaction transaction = new Transaction();
        transaction.setDescription(description);
        transaction.setAmount(amount);
        transaction.setType(TransactionType.valueOf(type));
        transaction.setCategory(category);
        transaction.setOccurredAt(Instant.now());
        transactionRepository.save(transaction);
    }

    @When("I request the limits progress")
    public void iRequestTheLimitsProgress() {
        ctx.response = restTemplate.getForEntity("/api/v1/limits/progress", String.class);
    }

    @And("the limits list is empty")
    public void theLimitsListIsEmpty() {
        assertThat((String) ctx.response.getBody()).isEqualTo("[]");
    }

    @And("the limit for {string} has spent {bigdecimal} and percentage {double}")
    public void theLimitForHasSpentAndPercentage(
            String categoryName, BigDecimal spent, double percentage) {
        assertThat((String) ctx.response.getBody())
                .contains("\"categoryName\":\"" + categoryName + "\"");
        assertThat((String) ctx.response.getBody())
                .contains("\"spent\":" + spent.stripTrailingZeros().toPlainString());
        assertThat((String) ctx.response.getBody()).contains("\"percentage\":" + percentage);
    }

    @When("I request all limits")
    public void iRequestAllLimits() {
        ctx.response = restTemplate.getForEntity("/api/v1/limits", String.class);
    }

    @When("I delete the last created limit")
    public void iDeleteTheLastCreatedLimit() {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/limits/" + ctx.lastLimitId, HttpMethod.DELETE, null, String.class);
    }

    @When("I delete limit with id {string}")
    public void iDeleteLimitWithId(String id) {
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/limits/" + UUID.fromString(id),
                        HttpMethod.DELETE,
                        null,
                        String.class);
    }

    @When("I update the last created limit amount to {bigdecimal}")
    public void iUpdateTheLastCreatedLimitAmountTo(BigDecimal amount) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity =
                new HttpEntity<>("{\"amount\":" + amount.toPlainString() + "}", headers);
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/limits/" + ctx.lastLimitId, HttpMethod.PUT, entity, String.class);
    }

    @When("I update limit with id {string} amount to {bigdecimal}")
    public void iUpdateLimitWithIdAmountTo(String id, BigDecimal amount) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity =
                new HttpEntity<>("{\"amount\":" + amount.toPlainString() + "}", headers);
        ctx.response =
                restTemplate.exchange(
                        "/api/v1/limits/" + UUID.fromString(id),
                        HttpMethod.PUT,
                        entity,
                        String.class);
    }

    @And("the all-limits list is empty")
    public void theAllLimitsListIsEmpty() {
        assertThat((String) ctx.response.getBody()).isEqualTo("[]");
    }

    @And("the all-limits list has {int} items")
    public void theAllLimitsListHasItems(int count) {
        long objCount = ((String) ctx.response.getBody()).chars().filter(c -> c == '{').count();
        assertThat(objCount).isEqualTo(count);
    }

    @And("the limit no longer exists")
    public void theLimitNoLongerExists() {
        assertThat(limitRepository.existsById(ctx.lastLimitId)).isFalse();
    }

    @And("the limit amount is {bigdecimal}")
    public void theLimitAmountIs(BigDecimal amount) {
        assertThat((String) ctx.response.getBody())
                .contains("\"amount\":" + amount.stripTrailingZeros().toPlainString());
    }
}
