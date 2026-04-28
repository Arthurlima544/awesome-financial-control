package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.GoalRequest;
import com.awesome.financial.control.afc.dto.GoalResponse;
import com.awesome.financial.control.afc.service.GoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/goals")
@RequiredArgsConstructor
@Validated
@Tag(name = "Goals")
public class GoalController {

    private final GoalService goalService;

    @GetMapping
    @Operation(summary = "List all savings goals")
    public List<GoalResponse> getAllGoals() {
        return goalService.getAllGoals();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new savings goal")
    public GoalResponse createGoal(@Valid @RequestBody GoalRequest request) {
        return goalService.createGoal(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing goal")
    public GoalResponse updateGoal(@PathVariable UUID id, @Valid @RequestBody GoalRequest request) {
        return goalService.updateGoal(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a goal")
    public void deleteGoal(@PathVariable UUID id) {
        goalService.deleteGoal(id);
    }

    @PatchMapping("/{id}/contribute")
    @Operation(summary = "Add a contribution to a goal")
    public GoalResponse addContribution(
            @PathVariable UUID id, @RequestParam @DecimalMin("0.01") BigDecimal amount) {
        return goalService.addContribution(id, amount);
    }
}
