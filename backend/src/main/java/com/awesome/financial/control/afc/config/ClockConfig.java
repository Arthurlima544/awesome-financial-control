package com.awesome.financial.control.afc.config;

import java.time.Clock;
import java.time.ZoneId;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ClockConfig {

    @Bean
    public Clock clock() {
        // Default to America/Sao_Paulo for all time-based logic in the app
        return Clock.system(ZoneId.of("America/Sao_Paulo"));
    }
}
