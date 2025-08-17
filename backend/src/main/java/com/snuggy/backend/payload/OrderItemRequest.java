package com.snuggy.backend.payload;

import lombok.Data;

@Data
public class OrderItemRequest {
    private Integer menuItemId;
    private int quantity;
} 