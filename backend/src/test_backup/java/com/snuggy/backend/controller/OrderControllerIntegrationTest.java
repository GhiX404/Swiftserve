package com.snuggy.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snuggy.backend.entity.Balance;
import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.entity.User;
import com.snuggy.backend.payload.OrderRequest;
import com.snuggy.backend.repository.BalanceRepository;
import com.snuggy.backend.repository.MenuRepository;
import com.snuggy.backend.repository.UserRepository;
import com.snuggy.backend.test.security.WithMockCustomUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class OrderControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MenuRepository menuRepository;

    @Autowired
    private BalanceRepository balanceRepository;
    
    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;
    private Menu testMenuItem;

    @BeforeEach
    void setup() {
        // Clear and set up test data before each test
        userRepository.deleteAll();
        menuRepository.deleteAll();
        balanceRepository.deleteAll();

        testUser = new User();
        testUser.setId(1);
        testUser.setEmail("testuser@example.com");
        testUser.setPassword("password");
        testUser.setName("Test User");
        userRepository.save(testUser);

        testMenuItem = new Menu();
        testMenuItem.setName("Test Item");
        testMenuItem.setPrice(new BigDecimal("10.00"));
        testMenuItem.setStock(100);
        menuRepository.save(testMenuItem);

        Balance balance = new Balance();
        balance.setStudentId(testUser.getId());
        balance.setAmount(new BigDecimal("50.00"));
        balanceRepository.save(balance);
    }

    @Test
    @WithMockCustomUser
    public void createOrder_shouldSucceed_whenDataIsValid() throws Exception {
        OrderItemRequest itemRequest = new OrderItemRequest();
        itemRequest.setMenuItemId(testMenuItem.getId());
        itemRequest.setQuantity(2);

        OrderRequest orderRequest = new OrderRequest();
        orderRequest.setItems(List.of(itemRequest));

        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(orderRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PENDING"));
    }
} 