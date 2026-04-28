package com.awesome.financial.control.afc.config;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import io.swagger.v3.core.converter.AnnotatedType;
import io.swagger.v3.core.converter.ModelConverters;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.Content;
import io.swagger.v3.oas.models.media.MediaType;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import java.util.Map;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!prod")
public class SwaggerConfig {

    private static final Map<String, String> ERROR_RESPONSES =
            Map.of(
                    "400", "Bad request",
                    "404", "Resource not found",
                    "409", "Conflict",
                    "422", "Validation error",
                    "500", "Internal server error");

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder().group("afc-public").pathsToMatch("/api/**").build();
    }

    @Bean
    public OpenAPI openAPI() {
        var errorSchema =
                ModelConverters.getInstance()
                        .resolveAsResolvedSchema(new AnnotatedType(ErrorResponse.class))
                        .schema;

        return new OpenAPI()
                .components(new Components().addSchemas("ErrorResponse", errorSchema))
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

    @Bean
    public OperationCustomizer globalErrorResponses() {
        return (operation, handlerMethod) -> {
            Schema<?> ref =
                    new Schema<>().$ref(Components.COMPONENTS_SCHEMAS_REF + "ErrorResponse");
            Content content =
                    new Content().addMediaType("application/json", new MediaType().schema(ref));

            ApiResponses responses = operation.getResponses();
            if (responses == null) {
                operation.setResponses(new ApiResponses());
                responses = operation.getResponses();
            }

            final ApiResponses finalResponses = responses;
            ERROR_RESPONSES.forEach(
                    (code, description) ->
                            finalResponses.putIfAbsent(
                                    code,
                                    new ApiResponse().description(description).content(content)));
            return operation;
        };
    }
}
