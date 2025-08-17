package com.snuggy.backend.payload;

import lombok.Data;

@Data
public class RfidRegisterRequest {
    private String rfidUid;
    private Integer studentId;
    private String otp;
    private String email;
} 