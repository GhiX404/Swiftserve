package com.snuggy.backend.repository;

import com.snuggy.backend.entity.RfidMapping;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RfidMappingRepository extends JpaRepository<RfidMapping, String> {
    Optional<RfidMapping> findByRfidUid(String rfidUid);
}
