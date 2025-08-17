package com.snuggy.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@Table(name = "rfid_mappings")
@Data
public class RfidMapping {
    @Id
    private String rfidUid;

    private Integer studentId;

    @CreationTimestamp
    private Timestamp createdAt;

    public RfidMapping() {
    }

    public RfidMapping(String rfidUid, Integer studentId) {
        this.rfidUid = rfidUid;
        this.studentId = studentId;
    }
}
