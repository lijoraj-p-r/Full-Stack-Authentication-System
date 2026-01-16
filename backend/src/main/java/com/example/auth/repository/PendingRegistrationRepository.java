package com.example.auth.repository;

import com.example.auth.entity.PendingRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PendingRegistrationRepository extends JpaRepository<PendingRegistration, Long> {
    Optional<PendingRegistration> findByEmail(String email);
    Boolean existsByEmail(String email);
    Boolean existsByUsername(String username);
    
    @Modifying
    @Query("DELETE FROM PendingRegistration p WHERE p.createdAt < ?1")
    void deleteOldPendingRegistrations(LocalDateTime cutoffTime);
    
    void deleteByEmail(String email);
}
