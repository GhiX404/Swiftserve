package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Transaction;
import com.snuggy.backend.entity.TransactionId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, TransactionId> {

    List<Transaction> findByUser_Id(Integer userId);

    @Query("SELECT SUM(t.amount) FROM Transaction t WHERE t.createdAt >= :startDate AND t.createdAt < :endDate")
    BigDecimal findEarningsBetweenDates(@Param("startDate") Date startDate, @Param("endDate") Date endDate);
    
    @Query("SELECT t FROM Transaction t JOIN FETCH t.user u JOIN FETCH t.order o")
    List<Transaction> findAllWithUserAndOrder();
    
    @Query("SELECT t FROM Transaction t JOIN FETCH t.user u JOIN FETCH t.order o WHERE u.id = :userId")
    List<Transaction> findByUserIdWithUserAndOrder(@Param("userId") Integer userId);
}
