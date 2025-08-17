package com.snuggy.backend.controller;

import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.exception.ResourceNotFoundException;
import com.snuggy.backend.payload.MenuRequest;
import com.snuggy.backend.payload.StockUpdateRequest;
import com.snuggy.backend.service.MenuService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/menu")
public class MenuController {

    private static final Logger logger = LoggerFactory.getLogger(MenuController.class);

    @Autowired
    private MenuService menuService;

    @GetMapping
    public List<Menu> getMenu(@RequestParam(required = false) Set<String> tags) {
        return menuService.getAllMenuItems(tags);
    }

    @PostMapping
    @PreAuthorize("hasRole('STAFF')")
    public Menu addMenuItem(@RequestBody MenuRequest menuRequest) {
        return menuService.addMenuItem(menuRequest);
    }

    @PutMapping("/{id}/stock")
    @PreAuthorize("hasRole('STAFF')")
    public ResponseEntity<Menu> updateStock(@PathVariable Integer id, @RequestBody StockUpdateRequest stockUpdate) {
        Integer quantityChange = stockUpdate.getQuantityChange();
        if (quantityChange == null) {
            return ResponseEntity.badRequest().build();
        }
        return menuService.updateStock(id, quantityChange)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResourceNotFoundException("Menu item not found with id: " + id));
    }
} 