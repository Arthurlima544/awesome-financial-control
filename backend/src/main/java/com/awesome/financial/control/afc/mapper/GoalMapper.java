package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.GoalResponse;
import com.awesome.financial.control.afc.model.Goal;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Component;

@Component
public class GoalMapper {

    public GoalResponse toResponse(Goal goal) {
        BigDecimal progress = BigDecimal.ZERO;
        if (goal.getTargetAmount() != null
                && goal.getTargetAmount().compareTo(BigDecimal.ZERO) > 0) {
            progress =
                    goal.getCurrentAmount()
                            .multiply(BigDecimal.valueOf(100))
                            .divide(goal.getTargetAmount(), 2, RoundingMode.HALF_UP);
        }

        return GoalResponse.builder()
                .id(goal.getId())
                .name(goal.getName())
                .targetAmount(goal.getTargetAmount())
                .currentAmount(goal.getCurrentAmount())
                .progressPercentage(progress)
                .deadline(goal.getDeadline())
                .icon(goal.getIcon())
                .createdAt(goal.getCreatedAt())
                .build();
    }
}
