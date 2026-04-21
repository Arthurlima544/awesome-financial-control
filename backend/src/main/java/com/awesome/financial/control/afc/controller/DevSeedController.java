package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.service.DevSeedService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dev")
@RequiredArgsConstructor
@Profile("local")
@Tag(name = "Dev Tools")
public class DevSeedController {

    private final DevSeedService devSeedService;

    @PostMapping("/seed")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Populate sample categories, limits and transactions (local only)")
    public void seed() {
        devSeedService.seed();
    }

    @DeleteMapping("/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete all data (local only)")
    public void reset() {
        devSeedService.reset();
    }
}
