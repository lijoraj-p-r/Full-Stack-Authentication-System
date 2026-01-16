package com.example.auth.service;

import com.example.auth.entity.OtpCode;
import com.example.auth.entity.OtpType;
import com.example.auth.entity.User;
import com.example.auth.repository.OtpCodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {
    private final OtpCodeRepository otpCodeRepository;
    private final Random random = new Random();

    @Value("${otp.expiration.minutes:5}")
    private int otpExpirationMinutes;

    @Value("${otp.rate-limit.minutes:1}")
    private int rateLimitMinutes;

    public String generateOtp() {
        return String.format("%06d", random.nextInt(1000000));
    }

    @Transactional
    public OtpCode createOtp(User user, OtpType type) {
        return createOtp(user, null, type);
    }

    @Transactional
    public OtpCode createOtpForEmail(String email, OtpType type) {
        return createOtp(null, email, type);
    }

    @Transactional
    public OtpCode createOtp(User user, String email, OtpType type) {
        // Check rate limiting
        LocalDateTime rateLimitTime = LocalDateTime.now().minusMinutes(rateLimitMinutes);
        Long recentOtps = 0L;
        
        if (user != null) {
            recentOtps = otpCodeRepository.countValidOtpsByUserAndType(user, type, rateLimitTime);
        } else if (email != null) {
            recentOtps = otpCodeRepository.countValidOtpsByEmailAndType(email, type, rateLimitTime);
        }
        
        if (recentOtps > 0) {
            throw new RuntimeException("Please wait before requesting another OTP");
        }

        // Invalidate previous unused OTPs
        otpCodeRepository.deleteExpiredOtps(LocalDateTime.now());

        String otpCode = generateOtp();
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(otpExpirationMinutes);

        OtpCode otp = new OtpCode();
        otp.setUser(user);
        otp.setEmail(email);
        otp.setOtpCode(otpCode);
        otp.setExpiryTime(expiryTime);
        otp.setType(type);
        otp.setUsed(false);

        return otpCodeRepository.save(otp);
    }

    @Transactional
    public boolean verifyOtp(User user, String otpCode, OtpType type) {
        if (user != null) {
            return verifyOtpByUser(user, otpCode, type);
        }
        return false;
    }

    @Transactional
    public boolean verifyOtpByEmail(String email, String otpCode, OtpType type) {
        OtpCode otp = otpCodeRepository
                .findByEmailAndOtpCodeAndTypeAndUsedFalse(email, otpCode, type)
                .orElse(null);

        if (otp == null) {
            log.warn("Invalid OTP for email: {}", email);
            return false;
        }

        if (otp.getExpiryTime().isBefore(LocalDateTime.now())) {
            log.warn("Expired OTP for email: {}", email);
            return false;
        }

        otp.setUsed(true);
        otpCodeRepository.save(otp);
        log.info("OTP verified successfully for email: {}", email);
        return true;
    }

    @Transactional
    public boolean verifyOtpByUser(User user, String otpCode, OtpType type) {
        OtpCode otp = otpCodeRepository
                .findByUserAndOtpCodeAndTypeAndUsedFalse(user, otpCode, type)
                .orElse(null);

        if (otp == null) {
            log.warn("Invalid OTP for user: {}", user.getEmail());
            return false;
        }

        if (otp.getExpiryTime().isBefore(LocalDateTime.now())) {
            log.warn("Expired OTP for user: {}", user.getEmail());
            return false;
        }

        otp.setUsed(true);
        otpCodeRepository.save(otp);
        log.info("OTP verified successfully for user: {}", user.getEmail());
        return true;
    }

    public void cleanupExpiredOtps() {
        otpCodeRepository.deleteExpiredOtps(LocalDateTime.now());
    }
}
