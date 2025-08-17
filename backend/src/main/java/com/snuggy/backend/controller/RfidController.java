package com.snuggy.backend.controller;

import com.snuggy.backend.entity.RfidMapping;
import com.snuggy.backend.exception.BadRequestException;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.AdminRfidRegisterRequest;
import com.snuggy.backend.payload.RfidRegisterRequest;
import com.snuggy.backend.security.UserPrincipal;
import com.snuggy.backend.service.OtpService;
import com.snuggy.backend.service.RfidService;
import com.snuggy.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/rfid")
public class RfidController {

    @Autowired
    private RfidService rfidService;

    @Autowired
    private OtpService otpService;
    
    @Autowired
    private UserService userService;

    @PostMapping("/request-otp")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> requestOtp(@AuthenticationPrincipal UserPrincipal currentUser) {
        otpService.generateAndSendOtp(currentUser.getEmail());
        return ResponseEntity.ok(Map.of("message", "OTP sent to your email"));
    }

    @PostMapping("/request-otp/{email}")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<?> requestOtpForUser(@PathVariable String email) {
        try {
            userService.getUserByEmail(email);
            otpService.generateAndSendOtp(email);
            return ResponseEntity.ok(Map.of("message", "OTP sent to " + email));
        } catch (ResourceNotFoundException e) {
            throw new BadRequestException("User not found with email: " + email);
        }
    }

    @PostMapping("/generate-otp")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> generateOtp(@AuthenticationPrincipal UserPrincipal currentUser) {

        otpService.generateAndSendOtp(currentUser.getEmail());
        return ResponseEntity.ok(Map.of("message", "OTP sent to your email"));
    }

    @PostMapping("/register")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> registerRfid(@RequestBody RfidRegisterRequest request, @AuthenticationPrincipal UserPrincipal currentUser) {
        if (!otpService.validateOtp(currentUser.getEmail(), request.getOtp())) {
            throw new BadRequestException("Invalid OTP");
        }
        RfidMapping newMapping = new RfidMapping(request.getRfidUid(), currentUser.getId());
        rfidService.registerRfid(newMapping);
        return ResponseEntity.ok(Map.of("message", "RFID registered successfully"));
    }

    @PostMapping("/admin/register")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<?> adminRegisterRfid(@RequestBody AdminRfidRegisterRequest request) {
        RfidMapping newMapping = new RfidMapping(request.getRfidUid(), request.getStudentId());
        rfidService.registerRfid(newMapping);
        return ResponseEntity.ok(Map.of("message", "RFID registered successfully for student " + request.getStudentId()));
    }
    
    @PostMapping("/admin/register-with-otp")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<?> adminRegisterRfidWithOtp(@RequestBody RfidRegisterRequest request) {
        if (!otpService.validateOtp(request.getEmail(), request.getOtp())) {
            throw new BadRequestException("Invalid OTP");
        }
        
        try {
            Integer userId = userService.getUserByEmail(request.getEmail()).getId();
            RfidMapping newMapping = new RfidMapping(request.getRfidUid(), userId);
            rfidService.registerRfid(newMapping);
            return ResponseEntity.ok(Map.of("message", "RFID registered successfully for " + request.getEmail()));
        } catch (ResourceNotFoundException e) {
            throw new BadRequestException("User not found with email: " + request.getEmail());
        }
    }

    @GetMapping("/{uid}")
    @PreAuthorize("hasAnyRole('STUDENT', 'STAFF')")
    public ResponseEntity<RfidMapping> getRfidMapping(@PathVariable String uid) {
        return rfidService.getRfidMapping(uid)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResourceNotFoundException("RFID mapping not found for UID: " + uid));
    }
} 