package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.FeedbackRequest;
import com.awesome.financial.control.afc.dto.FeedbackResponse;
import com.awesome.financial.control.afc.mapper.FeedbackMapper;
import com.awesome.financial.control.afc.model.Feedback;
import com.awesome.financial.control.afc.repository.FeedbackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMapper feedbackMapper;

    @Transactional
    public FeedbackResponse submitFeedback(FeedbackRequest request) {
        Feedback feedback =
                Feedback.builder()
                        .userId(request.userId())
                        .rating(request.rating())
                        .message(request.message())
                        .appVersion(request.appVersion())
                        .platform(request.platform())
                        .build();
        Feedback saved = feedbackRepository.save(feedback);
        return feedbackMapper.toResponse(saved);
    }
}
