package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.FeedbackResponse;
import com.awesome.financial.control.afc.model.Feedback;
import org.springframework.stereotype.Component;

@Component
public class FeedbackMapper {

    public FeedbackResponse toResponse(Feedback feedback) {
        return new FeedbackResponse(
                feedback.getId(),
                feedback.getUserId(),
                feedback.getRating(),
                feedback.getMessage(),
                feedback.getAppVersion(),
                feedback.getPlatform(),
                feedback.getCreatedAt());
    }
}
