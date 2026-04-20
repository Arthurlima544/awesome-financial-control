package com.awesome.financial.control.afc.steps;

import org.springframework.context.annotation.Scope;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Component
@Scope("cucumber-glue")
public class ScenarioContext {

    public ResponseEntity<String> response;
}
