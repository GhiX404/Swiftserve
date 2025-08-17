package com.snuggy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Entity
@Table(name = "balances")
@Data
public class Balance {
    @Id
    private Integer studentId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "student_id")
    private User user;

    private BigDecimal amount;

    @UpdateTimestamp
    private Timestamp lastUpdatedAt;
} 