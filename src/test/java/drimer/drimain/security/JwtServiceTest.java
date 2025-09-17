package drimer.drimain.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        // Initialize JwtService with test configuration - needs at least 32 bytes for HS256
        jwtService = new JwtService(60L, "", "test-secret-key-for-jwt-testing-32-bytes-minimum");
    }

    @Test
    void shouldGenerateAndParseToken() {
        // Given
        String username = "testuser";
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", "USER");

        // When
        String token = jwtService.generate(username, claims);
        String extractedUsername = jwtService.extractUsername(token);

        // Then
        assertNotNull(token);
        assertFalse(token.isEmpty());
        assertEquals(username, extractedUsername);
    }

    @Test
    void shouldValidateToken() {
        // Given
        String username = "testuser";
        Map<String, Object> claims = new HashMap<>();
        String token = jwtService.generate(username, claims);

        // When & Then
        assertTrue(jwtService.isValid(token, username));
        assertFalse(jwtService.isValid(token, "differentuser"));
    }

    @Test
    void shouldRejectInvalidToken() {
        // Given
        String invalidToken = "invalid.jwt.token";

        // When & Then
        assertThrows(Exception.class, () -> {
            jwtService.extractUsername(invalidToken);
        });
    }

    @Test
    void shouldHandleEmptyToken() {
        // When & Then
        assertThrows(Exception.class, () -> {
            jwtService.extractUsername("");
        });
        
        assertThrows(Exception.class, () -> {
            jwtService.extractUsername(null);
        });
    }
}