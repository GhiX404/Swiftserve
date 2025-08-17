package com.snuggy.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snuggy.backend.entity.Balance;
import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.entity.Order;
import com.snuggy.backend.entity.User;
import com.snuggy.backend.payload.OrderItemRequest;
import com.snuggy.backend.payload.OrderRequest;
import com.snuggy.backend.repository.OrderRepository;
import com.snuggy.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;
    @Mock
    private MenuService menuService;
    @Mock
    private BalanceService balanceService;
    @Mock
    private UserRepository userRepository;
    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private OrderService orderService;

    private User user;
    private Menu menuItem;
    private Balance balance;
    private OrderRequest orderRequest;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1);
        user.setEmail("test@test.com");

        menuItem = new Menu();
        menuItem.setId(1L);
        menuItem.setName("Test Item");
        menuItem.setPrice(BigDecimal.TEN);
        menuItem.setStock(10);

        balance = new Balance();
        balance.setStudentId(1);
        balance.setAmount(BigDecimal.valueOf(100));

        OrderItemRequest itemRequest = new OrderItemRequest();
        itemRequest.setMenuItemId(1L);
        itemRequest.setQuantity(2);
        orderRequest = new OrderRequest();
        orderRequest.setItems(Collections.singletonList(itemRequest));
    }

    @Test
    public void testCreateOrder_Success() throws Exception {
        when(userRepository.findById(1)).thenReturn(Optional.of(user));
        when(menuService.getMenuItem(1L)).thenReturn(Optional.of(menuItem));
        when(balanceService.getBalance(1)).thenReturn(Optional.of(balance));
        when(objectMapper.writeValueAsString(any())).thenReturn("{}");

        orderService.createOrder(orderRequest, 1);

        verify(balanceService, times(1)).updateBalance(1, BigDecimal.valueOf(80));
        verify(menuService, times(1)).updateStock(1L, -2);
        verify(orderRepository, times(1)).save(any(Order.class));
    }

    @Test
    public void testCreateOrder_InsufficientBalance() {
        balance.setAmount(BigDecimal.ONE); // Not enough for the order
        when(userRepository.findById(1)).thenReturn(Optional.of(user));
        when(menuService.getMenuItem(1L)).thenReturn(Optional.of(menuItem));
        when(balanceService.getBalance(1)).thenReturn(Optional.of(balance));

        assertThrows(RuntimeException.class, () -> {
            orderService.createOrder(orderRequest, 1);
        });
    }

    @Test
    public void testCreateOrder_InsufficientStock() {
        menuItem.setStock(1); // Not enough for the order
        when(userRepository.findById(1)).thenReturn(Optional.of(user));
        when(menuService.getMenuItem(1L)).thenReturn(Optional.of(menuItem));

        assertThrows(RuntimeException.class, () -> {
            orderService.createOrder(orderRequest, 1);
        });
    }
} 