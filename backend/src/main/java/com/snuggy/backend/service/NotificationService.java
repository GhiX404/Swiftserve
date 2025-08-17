package com.snuggy.backend.service;

import com.snuggy.backend.entity.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class NotificationService {

    private final SimpMessagingTemplate simpMessagingTemplate;

    @Autowired
    public NotificationService(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void sendNewOrderNotification(Order order) {
        System.out.println("Sending notification for new paid order: " + order.getId());
        simpMessagingTemplate.convertAndSend("/topic/staff/new-orders", Map.of("orderId", order.getId()));
    }

    public void sendLowStockWarning(String productName, int stock) {
        System.out.println("Sending low stock warning for: " + productName);
        simpMessagingTemplate.convertAndSend("/topic/staff/stock-alerts", Map.of("productName", productName, "stock", stock));
    }

    public void sendOrderConfirmationToStaff(Order order) {
        System.out.println("Sending collection confirmation for order: " + order.getId());
        simpMessagingTemplate.convertAndSend("/topic/staff/order-confirmations", Map.of("orderId", order.getId(), "status", "CONFIRMED"));
    }
} 