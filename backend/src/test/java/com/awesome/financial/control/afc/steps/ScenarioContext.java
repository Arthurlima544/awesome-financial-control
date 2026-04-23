package com.awesome.financial.control.afc.steps;

import com.awesome.financial.control.afc.dto.MonthlyReportResponse;
import java.util.UUID;
import org.springframework.context.annotation.Scope;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Component
@Scope("cucumber-glue")
public class ScenarioContext {

    public ResponseEntity<?> response;
    public ResponseEntity<MonthlyReportResponse> monthlyReportResponse;
    public UUID lastTransactionId;
    public UUID lastCategoryId;
    public UUID lastLimitId;
    public UUID lastTemplateId;
    public UUID lastRecurringId;
    public UUID lastGoalId;
    public UUID lastInvestmentId;
    public UUID lastBillId;
}
