package com.snuggy.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class OtpService {
    private final EmailService emailService;
    private final Map<String, OtpData> otpMap = new HashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private static final int OTP_EXPIRY_MINUTES = 5;
    private static final int OTP_LENGTH = 6;

    @Autowired
    public OtpService(EmailService emailService) {
        this.emailService = emailService;
    }

    public void generateAndSendOtp(String email) {
        String otp = generateOtp();
        otpMap.put(email, new OtpData(otp, LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES)));
        

        scheduler.schedule(() -> {
            otpMap.remove(email);
        }, OTP_EXPIRY_MINUTES, TimeUnit.MINUTES);
        

        emailService.sendOtpEmail(email, otp);
    }

    public boolean validateOtp(String email, String otp) {
        OtpData otpData = otpMap.get(email);
        
        if (otpData == null) {
            return false;
        }
        
        if (LocalDateTime.now().isAfter(otpData.expiryTime)) {
            otpMap.remove(email);
            return false;
        }
        
        if (otpData.otp.equals(otp)) {
            otpMap.remove(email);
            return true;
        }
        
        return false;
    }

    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder();
        
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        
        return otp.toString();
    }

    private static class OtpData {
        private final String otp;
        private final LocalDateTime expiryTime;
        
        public OtpData(String otp, LocalDateTime expiryTime) {
            this.otp = otp;
            this.expiryTime = expiryTime;
        }
    }
} 