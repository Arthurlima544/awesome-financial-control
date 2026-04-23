package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.BillRequest;
import com.awesome.financial.control.afc.dto.BillResponse;
import com.awesome.financial.control.afc.mapper.BillMapper;
import com.awesome.financial.control.afc.model.Bill;
import com.awesome.financial.control.afc.repository.BillRepository;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BillService {

    private final BillRepository billRepository;
    private final BillMapper billMapper;

    @Transactional(readOnly = true)
    public List<BillResponse> getAllBills() {
        return billRepository.findAll().stream().map(billMapper::toResponse).toList();
    }

    @Transactional
    public BillResponse createBill(BillRequest request) {
        Bill bill =
                Bill.builder()
                        .name(request.name())
                        .amount(request.amount())
                        .dueDay(request.dueDay())
                        .categoryId(request.categoryId())
                        .build();
        Bill saved = billRepository.save(bill);
        return billMapper.toResponse(saved);
    }

    @Transactional
    public BillResponse updateBill(UUID id, BillRequest request) {
        Bill bill = billRepository.findById(id).orElseThrow();
        bill.setName(request.name());
        bill.setAmount(request.amount());
        bill.setDueDay(request.dueDay());
        bill.setCategoryId(request.categoryId());
        Bill saved = billRepository.save(bill);
        return billMapper.toResponse(saved);
    }

    @Transactional
    public void deleteBill(UUID id) {
        billRepository.deleteById(id);
    }
}
