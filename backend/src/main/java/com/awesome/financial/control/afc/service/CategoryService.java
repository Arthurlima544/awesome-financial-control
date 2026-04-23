package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.CategoryResponse;
import com.awesome.financial.control.afc.dto.CreateCategoryRequest;
import com.awesome.financial.control.afc.dto.UpdateCategoryRequest;
import com.awesome.financial.control.afc.exception.ResourceNotFoundException;
import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(
                        c ->
                                CategoryResponse.builder()
                                        .id(c.getId())
                                        .name(c.getName())
                                        .createdAt(c.getCreatedAt())
                                        .build())
                .toList();
    }

    @Transactional
    public void deleteCategory(UUID id) {
        if (!categoryRepository.existsById(id)) {
            throw new ResourceNotFoundException("Category", id);
        }
        categoryRepository.deleteById(id);
    }

    @Transactional
    public CategoryResponse createCategory(CreateCategoryRequest request) {
        Category category = Category.builder().name(request.name()).build();
        Category saved = categoryRepository.save(category);
        return CategoryResponse.builder()
                .id(saved.getId())
                .name(saved.getName())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    @Transactional
    public CategoryResponse updateCategory(UUID id, UpdateCategoryRequest request) {
        Category category =
                categoryRepository
                        .findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Category", id));
        category.setName(request.name());
        Category saved = categoryRepository.save(category);
        return CategoryResponse.builder()
                .id(saved.getId())
                .name(saved.getName())
                .createdAt(saved.getCreatedAt())
                .build();
    }
}
