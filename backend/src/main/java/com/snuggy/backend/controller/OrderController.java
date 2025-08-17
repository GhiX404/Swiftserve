package com.snuggy.backend.controller;

import com.snuggy.backend.entity.Order;
import com.snuggy.backend.entity.OrderStatus;
import com.snuggy.backend.exception.BadRequestException;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.OrderRequest;
import com.snuggy.backend.security.UserPrincipal;
import com.snuggy.backend.service.OrderService;
import com.snuggy.backend.service.PaymentService;
import com.snuggy.backend.service.PushNotificationService;
import com.snuggy.backend.service.NotificationService;
import com.google.firebase.messaging.FirebaseMessagingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);

    @Autowired
    private OrderService orderService;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private PushNotificationService pushNotificationService;

    @Autowired
    private NotificationService notificationService;

    @GetMapping
    @PreAuthorize("hasRole('STAFF')")
    @Transactional(readOnly = true)
    public List<Order> getAllOrders() {
        return orderService.getAllOrders();
    }

    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public Order createOrder(@RequestBody OrderRequest orderRequest, @AuthenticationPrincipal UserPrincipal currentUser) {
        return orderService.createOrder(orderRequest, currentUser.getId());
    }

    @PostMapping("/{id}/pay/upi")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> payWithUpi(@PathVariable Integer id, @AuthenticationPrincipal UserPrincipal currentUser) {
        Order order = orderService.getOrderByIdAndUserId(id, currentUser.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + id));
        String transactionId = paymentService.initiatePayment(id, order.getTotalAmount());
        return ResponseEntity.ok(Map.of("transactionId", transactionId, "message", "Payment initiated."));
    }

    @GetMapping("/my-orders")
    @PreAuthorize("hasRole('STUDENT')")
    @Transactional(readOnly = true)
    public List<Order> getMyOrders(@AuthenticationPrincipal UserPrincipal currentUser) {
        return orderService.getOrdersByStudentId(currentUser.getId());
    }

    @GetMapping("/rfid/{uid}")
    @PreAuthorize("hasAnyRole('STUDENT', 'STAFF')")
    @Transactional(readOnly = true)
    public ResponseEntity<Order> getRfidOrders(@PathVariable String uid) {
        return orderService.getOrdersByRfidUid(uid)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResourceNotFoundException("No active orders found for RFID: " + uid));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable Integer id, @RequestBody Map<String, String> request) {
        String statusStr = request.get("status");
        if (statusStr == null) {
            throw new BadRequestException("Status is required.");
        }
        OrderStatus status;
        try {
            status = OrderStatus.valueOf(statusStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new BadRequestException("Invalid status value: " + statusStr);
        }
        return orderService.updateOrderStatus(id, status)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + id));
    }

    @PostMapping("/{id}/dispatch")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<?> dispatchOrder(@PathVariable Integer id) {
        Order order = orderService.getOrderById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + id));

        if (order.getStatus() != OrderStatus.PAID) {
            return ResponseEntity.badRequest().body("Order must be in PAID status to be dispatched.");
        }

        orderService.updateOrderStatus(id, OrderStatus.AWAITING_CONFIRMATION);

        String responseMessage = "Order status updated to AWAITING_CONFIRMATION.";
        
        if (order.getUser().getFcmToken() == null || order.getUser().getFcmToken().trim().isEmpty()) {
            responseMessage += " No FCM token available for user, notification not sent.";
        } else {
            try {
                pushNotificationService.sendNotificationToToken(
                        order.getUser().getFcmToken(),
                        "Order Ready for Collection",
                        "Please confirm collection for your order #" + order.getId(),
                        Map.of("orderId", String.valueOf(order.getId()))
                );
                responseMessage += " Notification sent to user for collection confirmation.";
            } catch (FirebaseMessagingException e) {
                logger.error("Failed to send push notification for orderId: {}", id, e);
                responseMessage += " Failed to send notification: " + e.getMessage();
            }
        }

        return ResponseEntity.ok(responseMessage);
    }

    @PostMapping("/{id}/confirm-collection")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<?> confirmCollection(@PathVariable Integer id, @AuthenticationPrincipal UserPrincipal currentUser) {
         Order order = orderService.getOrderById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id: " + id));

        if (!order.getUser().getId().equals(currentUser.getId())) {
            return ResponseEntity.status(403).body("You are not authorized to confirm this order.");
        }

        if (order.getStatus() != OrderStatus.AWAITING_CONFIRMATION) {
            return ResponseEntity.badRequest().body("Order is not awaiting confirmation.");
        }

        orderService.updateOrderStatus(id, OrderStatus.COMPLETED);
        
        notificationService.sendOrderConfirmationToStaff(order);
        
        return ResponseEntity.ok("Order collection confirmed.");
    }
} 