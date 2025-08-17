package com.snuggy.backend.service;

import com.snuggy.backend.entity.Transaction;
import com.snuggy.backend.repository.TransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Transactional(readOnly = true)
    public List<Transaction> getAllTransactions() {
        return transactionRepository.findAllWithUserAndOrder();
    }

    @Transactional(readOnly = true)
    public List<Transaction> getTransactionsByUserId(Integer userId) {
        return transactionRepository.findByUserIdWithUserAndOrder(userId);
    }

    public BigDecimal getDailyEarnings() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date startDate = cal.getTime();

        cal.add(Calendar.DATE, 1);
        Date endDate = cal.getTime();

        BigDecimal earnings = transactionRepository.findEarningsBetweenDates(startDate, endDate);
        return earnings == null ? BigDecimal.ZERO : earnings;
    }

    public Transaction saveTransaction(Transaction transaction) {
        return transactionRepository.save(transaction);
    }
} 