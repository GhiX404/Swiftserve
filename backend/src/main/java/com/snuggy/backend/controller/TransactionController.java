package com.snuggy.backend.controller;

import com.snuggy.backend.payload.TransactionDTO;
import com.snuggy.backend.security.UserPrincipal;
import com.snuggy.backend.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    @GetMapping
    @PreAuthorize("hasRole('STAFF')")
    @Transactional(readOnly = true)
    public List<TransactionDTO> getAllTransactions() {
        return transactionService.getAllTransactions().stream()
                .map(TransactionDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @GetMapping("/my-transactions")
    @PreAuthorize("hasRole('STUDENT')")
    @Transactional(readOnly = true)
    public List<TransactionDTO> getUserTransactions(@AuthenticationPrincipal UserPrincipal currentUser) {
        return transactionService.getTransactionsByUserId(currentUser.getId()).stream()
                .map(TransactionDTO::fromEntity)
                .collect(Collectors.toList());
    }
} 