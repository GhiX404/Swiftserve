package com.snuggy.backend.repository;

import com.snuggy.backend.entity.Menu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface MenuRepository extends JpaRepository<Menu, Integer> {
    List<Menu> findDistinctByTags_NameIn(Set<String> tags);
    
    @Query("SELECT m FROM Menu m LEFT JOIN FETCH m.tags WHERE m.id = :id")
    Optional<Menu> findByIdWithTags(@Param("id") Integer id);
    
    @Query("SELECT DISTINCT m FROM Menu m LEFT JOIN FETCH m.tags")
    List<Menu> findAllWithTags();
    
    @Query("SELECT DISTINCT m FROM Menu m LEFT JOIN FETCH m.tags t WHERE t.name IN :tagNames")
    List<Menu> findDistinctByTagsNameInWithTags(@Param("tagNames") Set<String> tagNames);
}
