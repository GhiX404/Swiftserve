package com.snuggy.backend.payload;

import com.snuggy.backend.entity.Transaction;
import lombok.Data;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
public class TransactionDTO {
    private Integer studentId;
    private Integer orderId;
    private String studentName;
    private String studentEmail;
    private BigDecimal amount;
    private Timestamp createdAt;
    
    public static TransactionDTO fromEntity(Transaction transaction) {
        TransactionDTO dto = new TransactionDTO();
        dto.setStudentId(transaction.getId().getStudentId());
        dto.setOrderId(transaction.getId().getOrderId());
        dto.setStudentName(transaction.getUser().getName());
        dto.setStudentEmail(transaction.getUser().getEmail());
        dto.setAmount(transaction.getAmount());
        dto.setCreatedAt(transaction.getCreatedAt());
        return dto;
    }
} 