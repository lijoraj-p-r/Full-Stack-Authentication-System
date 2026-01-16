package com.example.auth.service;

import com.example.auth.dto.AuthResponse;
import com.example.auth.dto.LoginRequest;
import com.example.auth.dto.RegisterRequest;
import com.example.auth.entity.OtpType;
import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    private final UserService userService;
    private final PendingRegistrationService pendingRegistrationService;
    private final OtpService otpService;
    private final EmailService emailService;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public void register(RegisterRequest request) {
        // Check if user already exists (verified or unverified)
        if (userService.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists. Please login or verify your email.");
        }
        if (userService.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        // Create pending registration (NOT in users table yet)
        var pendingRegistration = pendingRegistrationService.createPendingRegistration(
                request.getUsername(),
                request.getEmail(),
                request.getPassword(),
                Role.USER
        );

        // Create OTP for email (not linked to user since user doesn't exist yet)
        var otp = otpService.createOtpForEmail(pendingRegistration.getEmail(), OtpType.REGISTRATION);
        emailService.sendOtpEmail(pendingRegistration.getEmail(), otp.getOtpCode(), "REGISTRATION");
        log.info("Registration OTP sent to: {}", pendingRegistration.getEmail());
    }

    @Transactional
    public void verifyOtp(String email, String otpCode) {
        // Verify OTP using email (not user, since user doesn't exist yet)
        if (!otpService.verifyOtpByEmail(email, otpCode, OtpType.REGISTRATION)) {
            throw new RuntimeException("Invalid or expired OTP");
        }

        // Get pending registration
        var pendingRegistration = pendingRegistrationService.findByEmail(email);

        // Now create the actual user in users table with already hashed password
        User createdUser = userService.createUserWithHashedPassword(
                pendingRegistration.getUsername(),
                pendingRegistration.getEmail(),
                pendingRegistration.getPassword(), // Already hashed
                pendingRegistration.getRole()
        );

        // Verify the user was created correctly
        if (createdUser == null || !createdUser.getIsVerified()) {
            log.error("User creation failed or not verified for: {}", email);
            throw new RuntimeException("Failed to create verified user");
        }

        // Delete pending registration
        pendingRegistrationService.deleteByEmail(email);

        log.info("Email verified and user created successfully: {} (verified: {})", email, createdUser.getIsVerified());
    }

    public AuthResponse login(LoginRequest request) {
        User user = userService.findByEmail(request.getEmail());

        if (user == null) {
            log.error("User not found for email: {}", request.getEmail());
            throw new RuntimeException("Invalid email or password");
        }

        if (!user.getIsVerified()) {
            log.warn("Login attempted for unverified user: {}", request.getEmail());
            throw new RuntimeException("Please verify your email before logging in");
        }

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (Exception e) {
            log.error("Authentication failed for user: {} - {}", request.getEmail(), e.getMessage());
            throw new RuntimeException("Invalid email or password");
        }

        // Reload user to ensure we have latest data
        user = userService.findByEmail(request.getEmail());
        
        UserDetails userDetails = loadUserByUsername(user.getEmail());
        String accessToken = jwtService.generateToken(userDetails, user.getRole().name());
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        log.info("User logged in successfully: {} (verified: {})", user.getEmail(), user.getIsVerified());
        return new AuthResponse(
                accessToken,
                refreshToken,
                "Bearer",
                userService.toUserResponse(user)
        );
    }

    @Transactional
    public void forgotPassword(String email) {
        User user = userService.findByEmail(email);
        var otp = otpService.createOtp(user, OtpType.RESET_PASSWORD);
        emailService.sendOtpEmail(user.getEmail(), otp.getOtpCode(), "RESET_PASSWORD");
        log.info("Password reset OTP sent to: {}", email);
    }

    @Transactional
    public void resetPassword(String email, String otpCode, String newPassword) {
        User user = userService.findByEmail(email);

        if (!otpService.verifyOtp(user, otpCode, OtpType.RESET_PASSWORD)) {
            throw new RuntimeException("Invalid or expired OTP");
        }

        userService.updatePassword(email, newPassword);
        log.info("Password reset successfully for user: {}", email);
    }

    private UserDetails loadUserByUsername(String email) {
        User user = userService.findByEmail(email);
        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities("ROLE_" + user.getRole().name())
                .build();
    }
}
