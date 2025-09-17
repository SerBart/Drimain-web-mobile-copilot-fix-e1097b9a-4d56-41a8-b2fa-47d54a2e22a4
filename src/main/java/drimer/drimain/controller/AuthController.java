package drimer.drimain.controller;

import drimer.drimain.security.JwtService;
import drimer.drimain.service.CustomUserDetailsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Slf4j
@Tag(name = "Authentication", description = "User authentication and session management")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    public AuthController(AuthenticationManager authenticationManager,
                          JwtService jwtService,
                          CustomUserDetailsService userDetailsService) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    @PostMapping("/login")
    @Operation(summary = "User login", description = "Authenticate user and return JWT token")
    public ResponseEntity<?> login(@RequestBody AuthRequest request, HttpServletResponse response) {
        try {
            log.info("Login attempt for user: {}", request.getUsername());
            Authentication auth = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
            var userDetails = userDetailsService.loadUserByUsername(request.getUsername());
            Map<String, Object> claims = new HashMap<>();
            claims.put("roles", userDetails.getAuthorities()
                    .stream().map(a -> a.getAuthority()).toList());

            String token = jwtService.generate(userDetails.getUsername(), claims);

            // Set HttpOnly JWT cookie
            Cookie jwtCookie = new Cookie("JWT", token);
            jwtCookie.setHttpOnly(true);
            jwtCookie.setSecure(false); // Set to true in production with HTTPS
            jwtCookie.setPath("/");
            jwtCookie.setMaxAge(60 * 60); // 1 hour, same as JWT expiration
            response.addCookie(jwtCookie);

            log.info("Login successful for user: {}", request.getUsername());
            return ResponseEntity.ok(new AuthResponse(token));
        } catch (AuthenticationException e) {
            log.warn("Login failed for user: {} - {}", request.getUsername(), e.getMessage());
            return ResponseEntity.status(401).body(Map.of("error", "Bad credentials"));
        }
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user info", description = "Return username and roles for the authenticated user")
    public ResponseEntity<?> me(@RequestHeader(name = "Authorization", required = false) String authHeader,
                               HttpServletRequest request) {
        String token = null;

        // First try Authorization header
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        }

        // If no Authorization header, try JWT cookie
        if (token == null) {
            token = getJwtFromCookie(request);
        }

        if (token == null) {
            return ResponseEntity.status(401).body(Map.of("error", "No token"));
        }

        try {
            String username = jwtService.extractUsername(token);
            var userDetails = userDetailsService.loadUserByUsername(username);
            var roles = userDetails.getAuthorities()
                    .stream()
                    .map(a -> a.getAuthority())
                    .toList();
            
            return ResponseEntity.ok(new UserInfoResponse(username, roles));
        } catch (Exception ex) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid token"));
        }
    }

    private String getJwtFromCookie(HttpServletRequest request) {
        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("JWT".equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    @Data
    public static class AuthRequest {
        private String username;
        private String password;
    }

    @Data
    public static class AuthResponse {
        private final String token;
    }

    @Data
    public static class UserInfoResponse {
        private final String username;
        private final java.util.List<String> roles;
    }
}