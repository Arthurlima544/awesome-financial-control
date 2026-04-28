package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.GoalRequest;
import com.awesome.financial.control.afc.dto.GoalResponse;
import com.awesome.financial.control.afc.service.GoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
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
    @ApiResponse(responseCode = "200", description = "List of goals")
    public List<GoalResponse> getAllGoals() {
        return goalService.getAllGoals();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new savings goal")
    @ApiResponse(responseCode = "201", description = "Goal created")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public GoalResponse createGoal(@Valid @RequestBody GoalRequest request) {
        return goalService.createGoal(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing goal")
    @ApiResponse(responseCode = "200", description = "Goal updated")
    @ApiResponse(
            responseCode = "404",
            description = "Goal not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public GoalResponse updateGoal(@PathVariable UUID id, @Valid @RequestBody GoalRequest request) {
        return goalService.updateGoal(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a goal")
    @ApiResponse(responseCode = "204", description = "Goal deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Goal not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void deleteGoal(@PathVariable UUID id) {
        goalService.deleteGoal(id);
    }

    @PatchMapping("/{id}/contribute")
    @Operation(summary = "Add a contribution to a goal")
    @ApiResponse(responseCode = "200", description = "Contribution added")
    @ApiResponse(
            responseCode = "404",
            description = "Goal not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public GoalResponse addContribution(
            @PathVariable UUID id, @RequestParam @DecimalMin("0.01") BigDecimal amount) {
        return goalService.addContribution(id, amount);
    }
}
