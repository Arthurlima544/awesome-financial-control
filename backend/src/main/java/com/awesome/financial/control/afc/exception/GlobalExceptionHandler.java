package com.awesome.financial.control.afc.exception;

import com.awesome.financial.control.afc.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import java.time.format.DateTimeParseException;
import java.util.Locale;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.MessageSource;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Hidden
@Slf4j
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final MessageSource messageSource;

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleResourceNotFound(
            ResourceNotFoundException ex, HttpServletRequest req) {
        log.warn("Resource not found: {}", ex.getMessage());
        return new ErrorResponse(
                "NOT_FOUND", ex.getMessage(), HttpStatus.NOT_FOUND.value(), req.getRequestURI());
    }

    @ExceptionHandler(ConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleConflict(ConflictException ex, HttpServletRequest req) {
        log.warn("Conflict error: {}", ex.getMessage());
        return new ErrorResponse(
                "CONFLICT", ex.getMessage(), HttpStatus.CONFLICT.value(), req.getRequestURI());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ErrorResponse handleValidation(
            MethodArgumentNotValidException ex, HttpServletRequest req) {
        String message =
                ex.getBindingResult().getFieldErrors().stream()
                        .map(e -> e.getField() + ": " + e.getDefaultMessage())
                        .collect(Collectors.joining(", "));
        return new ErrorResponse(
                "VALIDATION_ERROR",
                message,
                HttpStatus.UNPROCESSABLE_ENTITY.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(ConstraintViolationException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ErrorResponse handleConstraintViolation(
            ConstraintViolationException ex, HttpServletRequest req) {
        String message =
                ex.getConstraintViolations().stream()
                        .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                        .collect(Collectors.joining(", "));
        return new ErrorResponse(
                "VALIDATION_ERROR",
                message,
                HttpStatus.UNPROCESSABLE_ENTITY.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(DateTimeParseException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleDateTimeParse(
            DateTimeParseException ex, HttpServletRequest req, Locale locale) {
        log.warn("Invalid date-time format: {}", ex.getMessage());
        return new ErrorResponse(
                "BAD_REQUEST",
                messageSource.getMessage("error.date_parse", null, locale),
                HttpStatus.BAD_REQUEST.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleIllegalArgument(
            IllegalArgumentException ex, HttpServletRequest req) {
        log.warn("Illegal argument: {}", ex.getMessage());
        return new ErrorResponse(
                "BAD_REQUEST",
                ex.getMessage(),
                HttpStatus.BAD_REQUEST.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleDataIntegrityViolation(
            DataIntegrityViolationException ex, HttpServletRequest req, Locale locale) {
        log.warn("Data integrity violation: {}", ex.getMessage());
        return new ErrorResponse(
                "CONFLICT",
                messageSource.getMessage("error.data_integrity", null, locale),
                HttpStatus.CONFLICT.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleHttpMessageNotReadable(
            HttpMessageNotReadableException ex, HttpServletRequest req, Locale locale) {
        log.warn("Malformed JSON request: {}", ex.getMessage());
        return new ErrorResponse(
                "BAD_REQUEST",
                messageSource.getMessage("error.unreadable", null, locale),
                HttpStatus.BAD_REQUEST.value(),
                req.getRequestURI());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGeneric(Exception ex, HttpServletRequest req, Locale locale) {
        log.error("Unexpected error", ex);
        return new ErrorResponse(
                "INTERNAL_ERROR",
                messageSource.getMessage("error.internal", null, locale),
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                req.getRequestURI());
    }
}
