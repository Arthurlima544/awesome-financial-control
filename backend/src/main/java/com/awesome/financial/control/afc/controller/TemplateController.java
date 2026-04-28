package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.CreateTemplateRequest;
import com.awesome.financial.control.afc.dto.ErrorResponse;
import com.awesome.financial.control.afc.dto.TemplateDTO;
import com.awesome.financial.control.afc.service.TemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
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
    @ApiResponse(responseCode = "200", description = "List of templates")
    public List<TemplateDTO> getAll() {
        return templateService.findAll();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new transaction template")
    @ApiResponse(responseCode = "201", description = "Template created")
    @ApiResponse(
            responseCode = "422",
            description = "Validation error",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public TemplateDTO create(@RequestBody @Valid CreateTemplateRequest request) {
        return templateService.create(request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a template by id")
    @ApiResponse(responseCode = "204", description = "Template deleted")
    @ApiResponse(
            responseCode = "404",
            description = "Template not found",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    public void delete(@PathVariable UUID id) {
        templateService.delete(id);
    }
}
