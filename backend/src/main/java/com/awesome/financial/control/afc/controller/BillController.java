package com.awesome.financial.control.afc.controller;

import com.awesome.financial.control.afc.dto.BillRequest;
import com.awesome.financial.control.afc.dto.BillResponse;
import com.awesome.financial.control.afc.service.BillService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/bills")
@RequiredArgsConstructor
@Tag(name = "Bills")
public class BillController {

    private final BillService billService;

    @GetMapping
    @Operation(summary = "Get all bills")
    public List<BillResponse> getAllBills() {
        return billService.getAllBills();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a new bill")
    public BillResponse createBill(@Valid @RequestBody BillRequest request) {
        return billService.createBill(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an existing bill")
    public BillResponse updateBill(@PathVariable UUID id, @Valid @RequestBody BillRequest request) {
        return billService.updateBill(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete a bill")
    public void deleteBill(@PathVariable UUID id) {
        billService.deleteBill(id);
    }
}
