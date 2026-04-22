package com.awesome.financial.control.afc.steps;

import java.util.UUID;
import org.springframework.context.annotation.Scope;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Component
@Scope("cucumber-glue")
public class ScenarioContext {

    public ResponseEntity<String> response;
    public UUID lastTransactionId;
    public UUID lastCategoryId;
    public UUID lastLimitId;
    public UUID lastTemplateId;
    public UUID lastRecurringId;
}
