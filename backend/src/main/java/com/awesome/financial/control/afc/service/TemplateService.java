package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.dto.CreateTemplateRequest;
import com.awesome.financial.control.afc.dto.TemplateDTO;
import com.awesome.financial.control.afc.mapper.TemplateMapper;
import com.awesome.financial.control.afc.model.Template;
import com.awesome.financial.control.afc.repository.TemplateRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TemplateService {
    private final TemplateRepository templateRepository;
    private final TemplateMapper templateMapper;

    @Transactional(readOnly = true)
    public List<TemplateDTO> findAll() {
        return templateRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(templateMapper::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public TemplateDTO create(CreateTemplateRequest request) {
        Template template =
                Template.builder()
                        .id(UUID.randomUUID())
                        .description(request.description())
                        .category(request.category())
                        .type(request.type())
                        .createdAt(LocalDateTime.now())
                        .build();

        return templateMapper.toDto(templateRepository.save(template));
    }

    @Transactional
    public void delete(UUID id) {
        if (!templateRepository.existsById(id)) {
            throw new RuntimeException("Template not found");
        }
        templateRepository.deleteById(id);
    }
}
