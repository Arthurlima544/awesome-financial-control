package com.awesome.financial.control.afc.utils;

import java.text.Normalizer;
import java.util.regex.Pattern;

public class StringNormalizer {

    private static final Pattern NONDIACRITICS_PATTERN =
            Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    public static String normalize(String value) {
        if (value == null) {
            return null;
        }
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD);
        return NONDIACRITICS_PATTERN.matcher(normalized).replaceAll("").toLowerCase().trim();
    }
}
