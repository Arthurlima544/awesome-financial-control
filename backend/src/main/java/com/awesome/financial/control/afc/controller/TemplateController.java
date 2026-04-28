package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CreateTemplateRequest;
import com.awesome.financial.control.afc.dto.TemplateDTO;
import com.awesome.financial.control.afc.service.TemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/templates")
@RequiredArgsConstructor
@Tag(name = "Templates")
public class TemplateController {
    private final TemplateService templateService;

    @GetMapping
    @Operation(summary = "List all transaction templates")
    public List<TemplateDTO> getAll() {
        return templateService.findAll();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new transaction template")
    public TemplateDTO create(@RequestBody @Valid CreateTemplateRequest request) {
        return templateService.create(request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a template by id")
    public void delete(@PathVariable UUID id) {
        templateService.delete(id);
    }
}
