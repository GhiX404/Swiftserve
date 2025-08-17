package com.snuggy.backend.service;

import com.snuggy.backend.entity.Menu;
import com.snuggy.backend.entity.Tag;
import com.snuggy.backend.payload.MenuRequest;
import com.snuggy.backend.repository.MenuRepository;
import com.snuggy.backend.repository.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class MenuService {

    @Autowired
    private MenuRepository menuRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private TagRepository tagRepository;

    public List<Menu> getAllMenuItems(Set<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return menuRepository.findAllWithTags();
        }
        return menuRepository.findDistinctByTagsNameInWithTags(tags);
    }

    public Optional<Menu> getMenuItem(Integer id) {
        return menuRepository.findByIdWithTags(id);
    }

    @Transactional
    public Menu addMenuItem(MenuRequest menuRequest) {
        Menu menu = new Menu();
        menu.setName(menuRequest.getName());
        menu.setPrice(menuRequest.getPrice());
        menu.setStock(menuRequest.getStock());
        menu.setImageUrl(menuRequest.getImageUrl());

        if (menuRequest.getTags() != null && !menuRequest.getTags().isEmpty()) {
            Set<Tag> tagSet = menuRequest.getTags().stream()
                    .map(tagName -> tagRepository.findByName(tagName)
                            .orElseGet(() -> tagRepository.save(new Tag(tagName))))
                    .collect(Collectors.toSet());
            menu.setTags(tagSet);
        }

        return menuRepository.save(menu);
    }

    @Transactional
    public Optional<Menu> updateStock(Integer id, Integer quantityChange) {
        return menuRepository.findByIdWithTags(id).map(menu -> {
            int newStock = menu.getStock() + quantityChange;
            menu.setStock(newStock);
            Menu updatedMenu = menuRepository.save(menu);


            if (newStock < 5) {
                notificationService.sendLowStockWarning(updatedMenu.getName(), newStock);
            }
            
            return updatedMenu;
        });
    }
}