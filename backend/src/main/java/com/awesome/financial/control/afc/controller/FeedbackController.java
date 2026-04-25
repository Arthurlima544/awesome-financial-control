package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.FeedbackRequest;
import com.awesome.financial.control.afc.dto.FeedbackResponse;
import com.awesome.financial.control.afc.service.FeedbackService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public FeedbackResponse submitFeedback(@Valid @RequestBody FeedbackRequest request) {
        return feedbackService.submitFeedback(request);
    }
}
