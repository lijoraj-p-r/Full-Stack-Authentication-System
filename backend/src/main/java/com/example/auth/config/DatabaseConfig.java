package com.example.auth.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Database configuration for optimization
 */
@Configuration
@EnableJpaRepositories(basePackages = "com.example.auth.repository")
@EnableTransactionManagement
public class DatabaseConfig {
    // Additional database optimizations can be added here
    // Connection pooling is configured in application.properties
}
