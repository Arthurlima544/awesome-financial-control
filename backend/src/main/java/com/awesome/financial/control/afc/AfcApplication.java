package com.awesome.financial.control.afc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class AfcApplication {

    public static void main(String[] args) {
        SpringApplication.run(AfcApplication.class, args);
    }
}
