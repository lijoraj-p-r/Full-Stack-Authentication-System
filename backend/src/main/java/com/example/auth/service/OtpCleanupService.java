package com.example.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Scheduled service to clean up expired OTPs and old pending registrations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OtpCleanupService {
    private final OtpService otpService;
    private final PendingRegistrationService pendingRegistrationService;

    /**
     * Clean up expired OTPs every hour
     */
    @Scheduled(fixedRate = 3600000) // 1 hour in milliseconds
    @Transactional
    public void cleanupExpiredOtps() {
        try {
            otpService.cleanupExpiredOtps();
            log.debug("Expired OTPs cleaned up successfully");
        } catch (Exception e) {
            log.error("Error cleaning up expired OTPs", e);
        }
    }

    /**
     * Clean up old pending registrations (older than 24 hours)
     * Runs every 6 hours
     */
    @Scheduled(fixedRate = 21600000) // 6 hours in milliseconds
    @Transactional
    public void cleanupOldPendingRegistrations() {
        try {
            LocalDateTime cutoffTime = LocalDateTime.now().minusHours(24);
            pendingRegistrationService.deleteOldPendingRegistrations(cutoffTime);
            log.debug("Old pending registrations cleaned up successfully (older than 24 hours)");
        } catch (Exception e) {
            log.error("Error cleaning up old pending registrations", e);
        }
    }
}
