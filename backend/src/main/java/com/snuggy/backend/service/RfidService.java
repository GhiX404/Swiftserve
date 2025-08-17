package com.snuggy.backend.service;

import com.snuggy.backend.entity.RfidMapping;
import com.snuggy.backend.repository.RfidMappingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class RfidService {

    @Autowired
    private RfidMappingRepository rfidMappingRepository;

    public RfidMapping registerRfid(RfidMapping rfidMapping) {
        return rfidMappingRepository.save(rfidMapping);
    }

    public Optional<RfidMapping> getRfidMapping(String uid) {
        return rfidMappingRepository.findByRfidUid(uid);
    }
} 