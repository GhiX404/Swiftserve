package com.snuggy.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class EmailService {
    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender emailSender;
    private final boolean emailEnabled;

    @Autowired
    public EmailService(@Nullable JavaMailSender emailSender) {
        this.emailSender = emailSender;
        this.emailEnabled = (emailSender != null);
    }

    public void sendSimpleMessage(String to, String subject, String text) {
        if (!emailEnabled) {
            logger.info("Email service disabled. Would have sent email to: {}, subject: {}, body: {}", to, subject, text);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            emailSender.send(message);
            logger.info("Email sent successfully to: {}", to);
        } catch (Exception e) {
            logger.error("Failed to send email to: {}", to, e);
        }
    }

    public void sendOtpEmail(String to, String otp) {
        String subject = "Your Snuggy RFID Registration OTP";
        String body = "Your OTP for RFID registration is: " + otp + "\n\n" +
                "This OTP will expire in 5 minutes.\n\n" +
                "If you did not request this OTP, please ignore this email.";
        
        sendSimpleMessage(to, subject, body);
    }
} 