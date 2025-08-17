package com.snuggy.backend.payload;

public class StockUpdateRequest {
    private Integer quantityChange;

    public Integer getQuantityChange() {
        return quantityChange;
    }

    public void setQuantityChange(Integer quantityChange) {
        this.quantityChange = quantityChange;
    }
} 