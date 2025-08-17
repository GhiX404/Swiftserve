package com.snuggy.backend.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class RequestSender {

    public static void main(String[] args) {
        try {

            String registerUrl = "http://localhost:8080/api/auth/register";
            String registerJson = "{\"name\": \"teststudent3\", \"email\": \"teststudent3@test.com\", \"password\": \"password\"}";
            sendRequest(registerUrl, registerJson);
            System.out.println("Registration request sent.");


            String loginUrl = "http://localhost:8080/api/auth/login";
            String loginJson = "{\"email\": \"teststudent3@test.com\", \"password\": \"password\"}";
            String loginResponse = sendRequest(loginUrl, loginJson);
            System.out.println("Login response: " + loginResponse);

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(loginResponse);
            String accessToken = rootNode.path("accessToken").asText();
            System.out.println("Access Token: " + accessToken);


            String orderUrl = "http://localhost:8080/api/orders";
            String orderJson = "{\"items\": [{\"menuItemId\": 1, \"quantity\": 1}]}";
            String orderResponse = sendAuthenticatedRequest(orderUrl, orderJson, accessToken);
            System.out.println("Order response: " + orderResponse);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String sendRequest(String urlString, String jsonInputString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; utf-8");
        conn.setRequestProperty("Accept", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        try (Scanner scanner = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8.name())) {
            return scanner.useDelimiter("\\\\A").next();
        }
    }

    private static String sendAuthenticatedRequest(String urlString, String jsonInputString, String token) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; utf-8");
        conn.setRequestProperty("Accept", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonInputString.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        try (Scanner scanner = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8.name())) {
            return scanner.useDelimiter("\\\\A").next();
        }
    }
} 