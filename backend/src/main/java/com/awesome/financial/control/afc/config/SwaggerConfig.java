package com.awesome.financial.control.afc.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!prod")
public class SwaggerConfig {

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder().group("afc-public").pathsToMatch("/api/**").build();
    }

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(
                        new Info()
                                .title("AFC API")
                                .description("Awesome Financial Control — REST API")
                                .version("0.1.0")
                                .contact(
                                        new Contact()
                                                .name("Arthur Lima")
                                                .email("arthurlima544@gmail.com")));
    }
}
