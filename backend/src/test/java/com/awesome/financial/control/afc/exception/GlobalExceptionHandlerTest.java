package com.awesome.financial.control.afc.exception;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import java.time.format.DateTimeParseException;
import java.util.Locale;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.MessageSource;

@ExtendWith(MockitoExtension.class)
class GlobalExceptionHandlerTest {

    @Mock private MessageSource messageSource;
    @InjectMocks private GlobalExceptionHandler handler;

    private HttpServletRequest request;

    @BeforeEach
    void setUp() {
        request = mock(HttpServletRequest.class);
        when(request.getRequestURI()).thenReturn("/api/v1/test");
    }

    @Test
    void handleResourceNotFound_returns404WithPath() {
        ResourceNotFoundException ex = new ResourceNotFoundException("Entity", "123");

        ErrorResponse response = handler.handleResourceNotFound(ex, request);

        assertThat(response.status()).isEqualTo(404);
        assertThat(response.code()).isEqualTo("NOT_FOUND");
        assertThat(response.message()).contains("Entity");
        assertThat(response.path()).isEqualTo("/api/v1/test");
        assertThat(response.timestamp()).isNotNull();
    }

    @Test
    void handleConflict_returns409WithPath() {
        ConflictException ex = new ConflictException("Duplicate entry");

        ErrorResponse response = handler.handleConflict(ex, request);

        assertThat(response.status()).isEqualTo(409);
        assertThat(response.code()).isEqualTo("CONFLICT");
        assertThat(response.message()).isEqualTo("Duplicate entry");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }

    @Test
    void handleIllegalArgument_returns400WithMessage() {
        IllegalArgumentException ex = new IllegalArgumentException("Valor inválido");

        ErrorResponse response = handler.handleIllegalArgument(ex, request);

        assertThat(response.status()).isEqualTo(400);
        assertThat(response.code()).isEqualTo("BAD_REQUEST");
        assertThat(response.message()).isEqualTo("Valor inválido");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }

    @Test
    void handleDateTimeParse_returns400WithLocalizedMessage() {
        when(messageSource.getMessage(eq("error.date_parse"), isNull(), any(Locale.class)))
                .thenReturn("Formato de mês inválido. Use yyyy-MM (ex: 2024-03)");
        DateTimeParseException ex = new DateTimeParseException("bad", "bad-value", 0);

        ErrorResponse response =
                handler.handleDateTimeParse(ex, request, Locale.forLanguageTag("pt-BR"));

        assertThat(response.status()).isEqualTo(400);
        assertThat(response.code()).isEqualTo("BAD_REQUEST");
        assertThat(response.message()).contains("yyyy-MM");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }

    @Test
    void handleHttpMessageNotReadable_returns400WithLocalizedMessage() {
        when(messageSource.getMessage(eq("error.unreadable"), isNull(), any(Locale.class)))
                .thenReturn("Corpo da requisição com formato inválido");
        org.springframework.http.converter.HttpMessageNotReadableException ex =
                new org.springframework.http.converter.HttpMessageNotReadableException(
                        "Malformed JSON", (org.springframework.http.HttpInputMessage) null);

        ErrorResponse response =
                handler.handleHttpMessageNotReadable(ex, request, Locale.forLanguageTag("pt-BR"));

        assertThat(response.status()).isEqualTo(400);
        assertThat(response.code()).isEqualTo("BAD_REQUEST");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }

    @Test
    void handleDataIntegrityViolation_returns409WithLocalizedMessage() {
        when(messageSource.getMessage(eq("error.data_integrity"), isNull(), any(Locale.class)))
                .thenReturn("A operação viola uma restrição de integridade de dados");
        org.springframework.dao.DataIntegrityViolationException ex =
                new org.springframework.dao.DataIntegrityViolationException("constraint");

        ErrorResponse response =
                handler.handleDataIntegrityViolation(ex, request, Locale.forLanguageTag("pt-BR"));

        assertThat(response.status()).isEqualTo(409);
        assertThat(response.code()).isEqualTo("CONFLICT");
        assertThat(response.message()).contains("integridade");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }

    @Test
    void handleGeneric_returns500WithLocalizedMessage() {
        when(messageSource.getMessage(eq("error.internal"), isNull(), any(Locale.class)))
                .thenReturn("Ocorreu um erro inesperado");
        Exception ex = new RuntimeException("Unexpected");

        ErrorResponse response = handler.handleGeneric(ex, request, Locale.forLanguageTag("pt-BR"));

        assertThat(response.status()).isEqualTo(500);
        assertThat(response.code()).isEqualTo("INTERNAL_ERROR");
        assertThat(response.path()).isEqualTo("/api/v1/test");
    }
}
