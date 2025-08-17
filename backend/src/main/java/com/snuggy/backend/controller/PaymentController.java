package com.snuggy.backend.controller;

import com.snuggy.backend.payload.PaymentCallbackRequest;
import com.snuggy.backend.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/callback")
    public ResponseEntity<?> handlePaymentCallback(@RequestBody PaymentCallbackRequest callbackRequest) {




        paymentService.handleCallback(callbackRequest);
        return ResponseEntity.ok().build();
    }
} 