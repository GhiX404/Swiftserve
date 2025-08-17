package com.snuggy.backend.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

@Service
public class PushNotificationService {

    private final FirebaseMessaging fcm;
    private final boolean firebaseEnabled;

    @Autowired
    public PushNotificationService(FirebaseMessaging fcm) {
        this.fcm = fcm;
        this.firebaseEnabled = (fcm != null);
    }

    public void sendNotificationToToken(String token, String title, String body, Map<String, String> data) throws FirebaseMessagingException {
        if (!firebaseEnabled) {

            System.out.println("Firebase disabled. Would have sent notification: " + title + " - " + body);
            return;
        }
        

        if (token == null || token.trim().isEmpty()) {
            System.out.println("FCM token is null or empty. Skipping notification: " + title + " - " + body);
            return;
        }
        
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        Message message = Message.builder()
                .setToken(token)
                .setNotification(notification)
                .putAllData(data)
                .build();

        fcm.send(message);
    }
} 