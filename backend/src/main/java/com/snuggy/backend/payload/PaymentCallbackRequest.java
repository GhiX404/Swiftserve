package com.snuggy.backend.payload;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PaymentCallbackRequest {
    private String transactionId;
    private Integer orderId;
    private BigDecimal amount;
    private String status;
} 