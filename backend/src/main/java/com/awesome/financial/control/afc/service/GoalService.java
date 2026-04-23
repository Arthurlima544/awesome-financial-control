package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.GoalRequest;
import com.awesome.financial.control.afc.dto.GoalResponse;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.mapper.GoalMapper;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.repository.GoalRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GoalService {

    private final GoalRepository goalRepository;
    private final GoalMapper goalMapper;

    @Transactional(readOnly = true)
    public List<GoalResponse> getAllGoals() {
        return goalRepository.findAll().stream().map(goalMapper::toResponse).toList();
    }

    @Transactional
    public GoalResponse createGoal(GoalRequest request) {
        Goal goal = new Goal();
        goal.setName(request.name());
        goal.setTargetAmount(request.targetAmount());
        goal.setCurrentAmount(
                request.currentAmount() != null ? request.currentAmount() : BigDecimal.ZERO);
        goal.setDeadline(request.deadline());
        goal.setIcon(request.icon());
        Goal saved = goalRepository.save(goal);
        return goalMapper.toResponse(saved);
    }

    @Transactional
    public GoalResponse updateGoal(UUID id, GoalRequest request) {
        Goal goal =
                goalRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Goal", id));
        goal.setName(request.name());
        goal.setTargetAmount(request.targetAmount());
        goal.setCurrentAmount(request.currentAmount());
        goal.setDeadline(request.deadline());
        goal.setIcon(request.icon());
        Goal saved = goalRepository.save(goal);
        return goalMapper.toResponse(saved);
    }

    @Transactional
    public void deleteGoal(UUID id) {
        if (!goalRepository.existsById(id)) {
            throw new ResourceNotFoundException("Goal", id);
        }
        goalRepository.deleteById(id);
    }

    @Transactional
    public GoalResponse addContribution(UUID id, BigDecimal amount) {
        Goal goal =
                goalRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Goal", id));
        goal.setCurrentAmount(goal.getCurrentAmount().add(amount));
        Goal saved = goalRepository.save(goal);
        return goalMapper.toResponse(saved);
    }
}
