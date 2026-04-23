package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.BillResponse;
import com.awesome.financial.control.afc.model.Bill;
import org.springframework.stereotype.Component;

@Component
public class BillMapper {

    public BillResponse toResponse(Bill bill) {
        return new BillResponse(
                bill.getId(),
                bill.getName(),
                bill.getAmount(),
                bill.getDueDay(),
                bill.getCategoryId());
    }
}
