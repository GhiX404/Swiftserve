package com.snuggy.backend.service;

import com.snuggy.backend.entity.Balance;
import com.snuggy.backend.repository.BalanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

@Service
public class BalanceService {

    @Autowired
    private BalanceRepository balanceRepository;

    public Optional<Balance> getBalance(Integer studentId) {
        return balanceRepository.findById(studentId);
    }

    public void updateBalance(Integer studentId, BigDecimal newAmount) {
        balanceRepository.findById(studentId).ifPresent(balance -> {
            balance.setAmount(newAmount);
            balanceRepository.save(balance);
        });
    }

    public void addFunds(Integer studentId, BigDecimal amountToAdd) {
        Balance balance = balanceRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Balance not found for user: " + studentId));
        balance.setAmount(balance.getAmount().add(amountToAdd));
        balanceRepository.save(balance);
    }
} 