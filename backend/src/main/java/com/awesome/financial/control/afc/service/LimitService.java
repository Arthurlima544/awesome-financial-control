package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.CreateLimitRequest;
import com.awesome.financial.control.afc.dto.LimitProgressResponse;
import com.awesome.financial.control.afc.dto.LimitResponse;
import com.awesome.financial.control.afc.dto.UpdateLimitRequest;
import com.awesome.financial.control.afc.exception.ConflictException;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LimitService {

    private final LimitRepository limitRepository;
    private final TransactionRepository transactionRepository;
    private final CategoryRepository categoryRepository;

    @Transactional
    public LimitResponse createLimit(CreateLimitRequest request) {
        Category category =
                categoryRepository
                        .findById(request.categoryId())
                        .orElseThrow(
                                () ->
                                        new ResourceNotFoundException(
                                                "Category", request.categoryId()));

        // Check if limit for this category already exists
        limitRepository.findAll().stream()
                .filter(l -> l.getCategory().getId().equals(request.categoryId()))
                .findAny()
                .ifPresent(
                        l -> {
                            throw new ConflictException(
                                    "A limit for category '"
                                            + category.getName()
                                            + "' already exists.");
                        });

        Limit limit = Limit.builder().category(category).amount(request.amount()).build();
        Limit saved = limitRepository.save(limit);

        return LimitResponse.builder()
                .id(saved.getId())
                .categoryName(saved.getCategory().getName())
                .amount(saved.getAmount())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public List<LimitResponse> getAllLimits() {
        return limitRepository.findAllWithCategory().stream()
                .map(
                        l ->
                                LimitResponse.builder()
                                        .id(l.getId())
                                        .categoryName(l.getCategory().getName())
                                        .amount(l.getAmount())
                                        .createdAt(l.getCreatedAt())
                                        .build())
                .toList();
    }

    @Transactional
    public void deleteLimit(UUID id) {
        if (!limitRepository.existsById(id)) {
            throw new ResourceNotFoundException("Limit", id);
        }
        limitRepository.deleteById(id);
    }

    @Transactional
    public LimitResponse updateLimit(UUID id, UpdateLimitRequest request) {
        Limit limit =
                limitRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Limit", id));
        limit.setAmount(request.amount());
        Limit saved = limitRepository.save(limit);
        return LimitResponse.builder()
                .id(saved.getId())
                .categoryName(saved.getCategory().getName())
                .amount(saved.getAmount())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public List<LimitProgressResponse> getLimitsWithProgress() {
        YearMonth current = YearMonth.now(ZoneOffset.UTC);
        Instant from = current.atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);
        Instant to = current.plusMonths(1).atDay(1).atStartOfDay().toInstant(ZoneOffset.UTC);

        return limitRepository.findAllWithCategory().stream()
                .map(
                        limit -> {
                            String categoryName = limit.getCategory().getName();
                            BigDecimal spent =
                                    transactionRepository
                                            .sumAmountByTypeAndCategoryAndOccurredAtBetween(
                                                    TransactionType.EXPENSE, categoryName, from, to)
                                            .orElse(BigDecimal.ZERO);
                            double percentage =
                                    limit.getAmount().compareTo(BigDecimal.ZERO) == 0
                                            ? 0.0
                                            : spent.multiply(BigDecimal.valueOf(100))
                                                    .divide(
                                                            limit.getAmount(),
                                                            2,
                                                            RoundingMode.HALF_UP)
                                                    .doubleValue();
                            return LimitProgressResponse.builder()
                                    .id(limit.getId())
                                    .categoryName(categoryName)
                                    .limitAmount(limit.getAmount())
                                    .spent(spent)
                                    .percentage(percentage)
                                    .build();
                        })
                .toList();
    }
}
