package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.FeedbackRequest;
import com.awesome.financial.control.afc.dto.FeedbackResponse;
import com.awesome.financial.control.afc.service.FeedbackService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/feedbacks")
@RequiredArgsConstructor
@Tag(name = "Feedback", description = "Endpoints for user feedback submission")
public class FeedbackController {

    private final FeedbackService feedbackService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Submit user feedback")
    @ApiResponse(responseCode = "201", description = "Feedback submitted")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public FeedbackResponse submitFeedback(@Valid @RequestBody FeedbackRequest request) {
        return feedbackService.submitFeedback(request);
    }
}
