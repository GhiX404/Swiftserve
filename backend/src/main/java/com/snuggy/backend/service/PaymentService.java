package com.snuggy.backend.service;

import com.snuggy.backend.entity.Order;
import com.snuggy.backend.entity.Transaction;
import com.snuggy.backend.entity.TransactionId;
import com.snuggy.backend.entity.OrderStatus;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.PaymentCallbackRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.UUID;

@Service
public class PaymentService {

    @Autowired
    private BalanceService balanceService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private NotificationService notificationService;

    public String initiatePayment(Integer orderId, BigDecimal amount) {

        String transactionId = UUID.randomUUID().toString();
        System.out.println("Initiating payment for order " + orderId + " of amount " + amount + ". Transaction ID: " + transactionId);
        return transactionId;
    }

    @Transactional
    public void handleCallback(PaymentCallbackRequest callbackRequest) {
        if ("SUCCESS".equalsIgnoreCase(callbackRequest.getStatus())) {
            Order order = orderService.getOrderById(callbackRequest.getOrderId())
                    .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + callbackRequest.getOrderId()));


            orderService.updateOrderStatus(order.getId(), OrderStatus.PAID);


            Transaction transaction = new Transaction();
            transaction.setId(new TransactionId(order.getUser().getId(), order.getId()));
            transaction.setUser(order.getUser());
            transaction.setOrder(order);
            transaction.setAmount(callbackRequest.getAmount());
            transaction.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            transactionService.saveTransaction(transaction);


            notificationService.sendNewOrderNotification(order);




        } else {
            System.out.println("Payment failed for order " + callbackRequest.getOrderId() + ". Reason: " + callbackRequest.getStatus());
        }
    }
}