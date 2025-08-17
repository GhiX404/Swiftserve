package com.snuggy.backend.controller;

import com.snuggy.backend.security.JwtTokenProvider;
import com.snuggy.backend.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import com.snuggy.backend.entity.User;
import com.snuggy.backend.repository.UserRepository;
import com.snuggy.backend.payload.LoginRequest;
import com.snuggy.backend.payload.SignUpRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.snuggy.backend.security.CustomUserDetailsService;
import com.snuggy.backend.repository.RoleRepository;
import com.snuggy.backend.entity.Role;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    JwtTokenProvider tokenProvider;

    @Autowired
    UserRepository userRepository;

    @Autowired
    RoleRepository roleRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    private CustomUserDetailsService customUserDetailsService;

    @PostMapping("/login")
    @Transactional
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        logger.info("Login attempt for email: {}", loginRequest.getEmail());
        
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getEmail(),
                            loginRequest.getPassword()
                    )
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
            logger.info("User authenticated successfully: {}, with roles: {}", userPrincipal.getEmail(), userPrincipal.getAuthorities());
            
            String accessToken = tokenProvider.generateAccessToken(userPrincipal);
            String refreshToken = tokenProvider.generateRefreshToken(userPrincipal);

            Map<String, String> response = new HashMap<>();
            response.put("accessToken", accessToken);
            response.put("refreshToken", refreshToken);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Authentication failed for user: {}", loginRequest.getEmail(), e);

            throw e;
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        if (refreshToken != null && tokenProvider.validateToken(refreshToken)) {
            Integer userId = tokenProvider.getUserIdFromJWT(refreshToken);
            UserPrincipal userPrincipal = (UserPrincipal) customUserDetailsService.loadUserById(userId);
            String newAccessToken = tokenProvider.generateAccessToken(userPrincipal);
            Map<String, String> response = new HashMap<>();
            response.put("accessToken", newAccessToken);
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body("Invalid refresh token");
        }
    }

    @PostMapping("/signup")
    @Transactional
    public ResponseEntity<?> registerUser(@RequestBody SignUpRequest signUpRequest) {
        logger.info("Registration attempt for email: {}", signUpRequest.getEmail());
        
        if(userRepository.findByEmail(signUpRequest.getEmail()).isPresent()) {
            logger.warn("Registration failed: Email {} is already taken", signUpRequest.getEmail());
            return ResponseEntity
                    .badRequest()
                    .body(Map.of("error", "Email is already taken!"));
        }

        try {

            User user = new User();
            user.setName(signUpRequest.getName());
            user.setEmail(signUpRequest.getEmail());
            user.setPassword(passwordEncoder.encode(signUpRequest.getPassword()));

            Role userRole = roleRepository.findByName(Role.ERole.ROLE_STUDENT)
                    .orElseThrow(() -> new RuntimeException("Error: Role is not found."));
            user.setRoles(Collections.singleton(userRole));

            userRepository.save(user);
            logger.info("User registered successfully: {}", signUpRequest.getEmail());

            Map<String, String> response = new HashMap<>();
            response.put("message", "User registered successfully!");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Registration failed for user: {}", signUpRequest.getEmail(), e);
            throw e;
        }
    }
}