package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.CategoryResponse;
import com.awesome.financial.control.afc.dto.CreateCategoryRequest;
import com.awesome.financial.control.afc.model.Category;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {

    public CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .createdAt(category.getCreatedAt())
                .build();
    }

    public Category toEntity(CreateCategoryRequest request) {
        return Category.builder().name(request.name()).build();
    }
}
