package com.awesome.financial.control.afc.mapper;

import com.awesome.financial.control.afc.dto.TemplateDTO;
import com.awesome.financial.control.afc.model.Template;
import org.springframework.stereotype.Component;

@Component
public class TemplateMapper {
    public TemplateDTO toDto(Template template) {
        return new TemplateDTO(
                template.getId(),
                template.getDescription(),
                template.getCategory(),
                template.getType());
    }
}
