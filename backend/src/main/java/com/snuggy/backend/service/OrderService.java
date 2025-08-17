package com.snuggy.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.entity.Order;
import com.snuggy.backend.entity.OrderItem;
import com.snuggy.backend.entity.User;
import com.snuggy.backend.entity.OrderStatus;
import com.snuggy.backend.entity.Transaction;
import com.snuggy.backend.entity.TransactionId;
import com.snuggy.backend.exception.BadRequestException;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.OrderRequest;
import com.snuggy.backend.repository.OrderRepository;
import com.snuggy.backend.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private MenuService menuService;

    @Autowired
    private BalanceService balanceService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private RfidService rfidService;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private NotificationService notificationService;

    public List<Order> getAllOrders() {
        return orderRepository.findAllWithUserAndRoles();
    }

    public List<Order> getOrdersByStudentId(Integer studentId) {
        return orderRepository.findByStudentIdWithUserAndRoles(studentId);
    }
    
    public Optional<Order> getMostRecentActiveOrderByStudentId(Integer studentId) {
        List<OrderStatus> activeStatuses = Arrays.asList(OrderStatus.PAID, OrderStatus.AWAITING_CONFIRMATION);
        List<Order> activeOrders = orderRepository.findActiveOrdersByStudentId(studentId, activeStatuses);
        return activeOrders.isEmpty() ? Optional.empty() : Optional.of(activeOrders.get(0));
    }

    public Optional<Order> getOrdersByRfidUid(String rfidUid) {
        Integer studentId = rfidService.getRfidMapping(rfidUid)
                .orElseThrow(() -> new ResourceNotFoundException("RFID UID not mapped to any student: " + rfidUid))
                .getStudentId();
        return getMostRecentActiveOrderByStudentId(studentId);
    }

    @Transactional
    public Order createOrder(OrderRequest orderRequest, Integer studentId) {
        User user = userRepository.findByIdWithRoles(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + studentId));

        BigDecimal totalCost = BigDecimal.ZERO;
        Order order = new Order();
        order.setUser(user);
        order.setStatus(OrderStatus.PENDING);

        for (var itemRequest : orderRequest.getItems()) {
            Menu menuItem = menuService.getMenuItem(itemRequest.getMenuItemId())
                    .orElseThrow(() -> new ResourceNotFoundException("Menu item not found: " + itemRequest.getMenuItemId()));

            if (menuItem.getStock() < itemRequest.getQuantity()) {
                throw new BadRequestException("Not enough stock for menu item: " + menuItem.getName());
            }

            BigDecimal itemCost = menuItem.getPrice().multiply(BigDecimal.valueOf(itemRequest.getQuantity()));
            totalCost = totalCost.add(itemCost);

            OrderItem orderItem = new OrderItem(order, menuItem, itemRequest.getQuantity(), menuItem.getPrice());
            order.getOrderItems().add(orderItem);
        }

        order.setTotalAmount(totalCost);

        BigDecimal currentBalance = balanceService.getBalance(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Balance not found for user with id: " + studentId))
                .getAmount();

        if (currentBalance.compareTo(totalCost) < 0) {
            throw new BadRequestException("Insufficient balance");
        }


        for (var orderItem : order.getOrderItems()) {
            menuService.updateStock(orderItem.getMenuItem().getId(), -orderItem.getQuantity());
        }


        balanceService.updateBalance(studentId, currentBalance.subtract(totalCost));


        Order savedOrder = orderRepository.save(order);
        

        savedOrder.setStatus(OrderStatus.PAID);
        savedOrder.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        savedOrder = orderRepository.save(savedOrder);
        

        Transaction transaction = new Transaction();
        transaction.setId(new TransactionId(user.getId(), savedOrder.getId()));
        transaction.setUser(user);
        transaction.setOrder(savedOrder);
        transaction.setAmount(totalCost);
        transaction.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        transactionService.saveTransaction(transaction);
        

        notificationService.sendNewOrderNotification(savedOrder);

        return savedOrder;
    }

    public Optional<Order> getOrderById(Integer id) {
        return orderRepository.findByIdWithUserAndRoles(id);
    }

    public Optional<Order> getOrderByIdAndUserId(Integer id, Integer userId) {
        return orderRepository.findByIdAndUserId(id, userId);
    }

    public Optional<Order> updateOrderStatus(Integer id, OrderStatus status) {
        return orderRepository.findByIdWithUserAndRoles(id).map(order -> {
            order.setStatus(status);
            return orderRepository.save(order);
        });
    }
} 