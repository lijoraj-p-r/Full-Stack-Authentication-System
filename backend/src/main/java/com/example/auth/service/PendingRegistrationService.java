package com.example.auth.service;

import com.example.auth.entity.PendingRegistration;
import com.example.auth.entity.Role;
import com.example.auth.repository.PendingRegistrationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class PendingRegistrationService {
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public PendingRegistration createPendingRegistration(String username, String email, String password, Role role) {
        if (pendingRegistrationRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already registered. Please verify your email or use a different email.");
        }
        if (pendingRegistrationRepository.existsByUsername(username)) {
            throw new RuntimeException("Username already exists");
        }

        PendingRegistration pending = new PendingRegistration();
        pending.setUsername(username);
        pending.setEmail(email);
        pending.setPassword(passwordEncoder.encode(password));
        pending.setRole(role != null ? role : Role.USER);

        PendingRegistration saved = pendingRegistrationRepository.save(pending);
        log.info("Pending registration created for: {}", email);
        return saved;
    }

    public PendingRegistration findByEmail(String email) {
        return pendingRegistrationRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Pending registration not found"));
    }

    @Transactional
    public void deleteByEmail(String email) {
        pendingRegistrationRepository.deleteByEmail(email);
        log.info("Pending registration deleted for: {}", email);
    }

    @Transactional
    public void deleteOldPendingRegistrations(LocalDateTime cutoffTime) {
        pendingRegistrationRepository.deleteOldPendingRegistrations(cutoffTime);
        log.info("Old pending registrations deleted (older than: {})", cutoffTime);
    }
}
