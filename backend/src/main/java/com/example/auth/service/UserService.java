package com.example.auth.service;

import com.example.auth.dto.UserResponse;
import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import com.example.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public User createUser(String username, String email, String password, Role role) {
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already exists");
        }
        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("Username already exists");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole(role != null ? role : Role.USER);
        user.setIsVerified(false);

        User savedUser = userRepository.save(user);
        log.info("User created: {}", savedUser.getEmail());
        return savedUser;
    }

    @Transactional
    public User createUserWithHashedPassword(String username, String email, String hashedPassword, Role role) {
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email already exists");
        }
        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("Username already exists");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(hashedPassword); // Already hashed
        user.setRole(role != null ? role : Role.USER);
        user.setIsVerified(true); // Verified since OTP was checked

        User savedUser = userRepository.save(user);
        
        // Verify the user was saved correctly
        if (savedUser == null || savedUser.getId() == null) {
            log.error("Failed to save user: {}", email);
            throw new RuntimeException("Failed to create user");
        }
        
        // Double-check isVerified is set
        if (!savedUser.getIsVerified()) {
            log.warn("User created but isVerified is false, setting to true: {}", email);
            savedUser.setIsVerified(true);
            savedUser = userRepository.save(savedUser);
        }
        
        log.info("User created with hashed password: {} (id: {}, verified: {})", 
                savedUser.getEmail(), savedUser.getId(), savedUser.getIsVerified());
        return savedUser;
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    @Transactional
    public User saveUser(User user) {
        return userRepository.save(user);
    }

    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Transactional
    public void verifyUser(String email) {
        User user = findByEmail(email);
        user.setIsVerified(true);
        userRepository.save(user);
        log.info("User verified: {}", email);
    }

    @Transactional
    public void updatePassword(String email, String newPassword) {
        User user = findByEmail(email);
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        log.info("Password updated for user: {}", email);
    }

    public UserResponse toUserResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.getIsVerified(),
                user.getCreatedAt()
        );
    }
}
