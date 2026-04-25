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
        Feedback feedback = new Feedback();
        feedback.setUserId(request.userId());
        feedback.setRating(request.rating());
        feedback.setMessage(request.message());
        feedback.setAppVersion(request.appVersion());
        feedback.setPlatform(request.platform());

        Feedback saved = feedbackRepository.save(feedback);
        return feedbackMapper.toResponse(saved);
    }
}
