package com.example.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {
    private final JavaMailSender mailSender;

    public void sendOtpEmail(String to, String otpCode, String type) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(getSubject(type));
            message.setText(getEmailBody(otpCode, type));
            
            mailSender.send(message);
            log.info("OTP email sent successfully to: {}", to);
        } catch (Exception e) {
            log.error("Failed to send email to: {}", to, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }

    private String getSubject(String type) {
        return switch (type) {
            case "REGISTRATION" -> "Verify Your Account - OTP Code";
            case "RESET_PASSWORD" -> "Reset Your Password - OTP Code";
            default -> "Your OTP Code";
        };
    }

    private String getEmailBody(String otpCode, String type) {
        String action = type.equals("REGISTRATION") ? "verify your account" : "reset your password";
        return String.format("""
                Hello,
                
                Your OTP code to %s is: %s
                
                This code will expire in 5 minutes.
                
                If you didn't request this code, please ignore this email.
                
                Best regards,
                Auth Service Team
                """, action, otpCode);
    }
}
