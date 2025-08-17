package com.snuggy.backend.service;

import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.repository.MenuRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class MenuServiceTest {

    @Mock
    private MenuRepository menuRepository;

    @InjectMocks
    private MenuService menuService;

    @Test
    public void testGetAllMenuItems() {
        Menu menu = new Menu();
        menu.setName("Test Item");
        when(menuRepository.findAll()).thenReturn(Collections.singletonList(menu));

        List<Menu> menuItems = menuService.getAllMenuItems();
        assertEquals(1, menuItems.size());
        assertEquals("Test Item", menuItems.get(0).getName());
    }
} 