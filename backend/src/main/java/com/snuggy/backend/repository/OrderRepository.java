package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Order;
import com.snuggy.backend.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.user u JOIN FETCH u.roles LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.menuItem ORDER BY o.createdAt DESC")
    List<Order> findAllWithUserAndRoles();
    
    List<Order> findByUserId(Integer userId);
    List<Order> findByUserIdAndStatus(Integer userId, String status);
    List<Order> findByUser_Id(Integer studentId);
    
    @Query("SELECT o FROM Order o JOIN FETCH o.user u JOIN FETCH u.roles LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.menuItem WHERE o.id = :id")
    Optional<Order> findByIdWithUserAndRoles(@Param("id") Integer id);
    
    @Query("SELECT o FROM Order o WHERE o.id = :id AND o.user.id = :userId")
    Optional<Order> findByIdAndUserId(@Param("id") Integer id, @Param("userId") Integer userId);
    
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.user u JOIN FETCH u.roles LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.menuItem WHERE u.id = :studentId")
    List<Order> findByStudentIdWithUserAndRoles(@Param("studentId") Integer studentId);
    
    @Query("SELECT DISTINCT o FROM Order o JOIN FETCH o.user u JOIN FETCH u.roles LEFT JOIN FETCH o.orderItems oi LEFT JOIN FETCH oi.menuItem " +
           "WHERE u.id = :studentId AND o.status IN :activeStatuses " +
           "ORDER BY o.createdAt DESC")
    List<Order> findActiveOrdersByStudentId(@Param("studentId") Integer studentId, @Param("activeStatuses") List<OrderStatus> activeStatuses);
}
