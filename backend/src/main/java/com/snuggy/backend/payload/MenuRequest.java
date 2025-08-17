package com.snuggy.backend.payload;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Set;

@Data
public class MenuRequest {
    private String name;
    private BigDecimal price;
    private Integer stock;
    private String imageUrl;
    private Set<String> tags;
} 