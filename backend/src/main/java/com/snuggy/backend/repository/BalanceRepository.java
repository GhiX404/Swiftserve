package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Balance;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BalanceRepository extends JpaRepository<Balance, Integer> {
} 