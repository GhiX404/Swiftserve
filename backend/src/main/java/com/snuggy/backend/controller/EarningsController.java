package com.snuggy.backend.controller;

import com.snuggy.backend.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/earnings")
public class EarningsController {

    @Autowired
    private TransactionService transactionService;

    @GetMapping("/daily")
    @PreAuthorize("hasRole('STAFF')")
    public Map<String, BigDecimal> getDailyEarnings() {
        return Map.of("dailyEarnings", transactionService.getDailyEarnings());
    }
} 