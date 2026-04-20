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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;

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
        categoryRepository.save(category);
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
        limitRepository.save(limit);
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
        assertThat(ctx.response.getBody()).isEqualTo("[]");
    }

    @And("the limit for {string} has spent {bigdecimal} and percentage {double}")
    public void theLimitForHasSpentAndPercentage(
            String categoryName, BigDecimal spent, double percentage) {
        assertThat(ctx.response.getBody()).contains("\"categoryName\":\"" + categoryName + "\"");
        assertThat(ctx.response.getBody())
                .contains("\"spent\":" + spent.stripTrailingZeros().toPlainString());
        assertThat(ctx.response.getBody()).contains("\"percentage\":" + percentage);
    }
}
