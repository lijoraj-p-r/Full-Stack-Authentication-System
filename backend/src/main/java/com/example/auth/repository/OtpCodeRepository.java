package com.example.auth.repository;

import com.example.auth.entity.OtpCode;
import com.example.auth.entity.OtpType;
import com.example.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {
    Optional<OtpCode> findByUserAndOtpCodeAndTypeAndUsedFalse(User user, String otpCode, OtpType type);
    
    Optional<OtpCode> findByEmailAndOtpCodeAndTypeAndUsedFalse(String email, String otpCode, OtpType type);
    
    @Query("SELECT COUNT(o) FROM OtpCode o WHERE o.user = ?1 AND o.type = ?2 AND o.expiryTime > ?3 AND o.used = false")
    Long countValidOtpsByUserAndType(User user, OtpType type, LocalDateTime now);
    
    @Query("SELECT COUNT(o) FROM OtpCode o WHERE o.email = ?1 AND o.type = ?2 AND o.expiryTime > ?3 AND o.used = false")
    Long countValidOtpsByEmailAndType(String email, OtpType type, LocalDateTime now);
    
    @Modifying
    @Query("DELETE FROM OtpCode o WHERE o.expiryTime < ?1")
    void deleteExpiredOtps(LocalDateTime now);
}
