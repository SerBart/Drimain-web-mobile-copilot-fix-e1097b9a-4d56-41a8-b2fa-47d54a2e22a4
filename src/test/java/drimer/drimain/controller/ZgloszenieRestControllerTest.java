package drimer.drimain.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import drimer.drimain.DriMainApplication;
import drimer.drimain.api.dto.ZgloszenieCreateRequest;
import drimer.drimain.model.Role;
import drimer.drimain.model.User;
import drimer.drimain.model.Zgloszenie;
import drimer.drimain.model.enums.ZgloszenieStatus;
import drimer.drimain.repository.RoleRepository;
import drimer.drimain.repository.UserRepository;
import drimer.drimain.repository.ZgloszenieRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static org.hamcrest.Matchers.*;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = DriMainApplication.class)
@Transactional
class ZgloszenieRestControllerTest {

    private MockMvc mockMvc;

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ZgloszenieRepository zgloszenieRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private User testUser;
    private final String testUsername = "testuser";
    private final String testPassword = "testpass123";

    @BeforeEach
    void setUp() {
        // Set up MockMvc with Spring Security
        mockMvc = MockMvcBuilders
                .webAppContextSetup(webApplicationContext)
                .apply(springSecurity())
                .build();

        // Create test user with role
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> {
                    Role role = new Role();
                    role.setName("ROLE_USER");
                    return roleRepository.save(role);
                });

        testUser = new User();
        testUser.setUsername(testUsername);
        testUser.setPassword(passwordEncoder.encode(testPassword));
        testUser.setRoles(Set.of(userRole));
        userRepository.save(testUser);
    }

    @Test
    void shouldReturnUnauthorizedWhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/zgloszenia"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"USER"})
    void shouldReturnZgloszeniaListWhenAuthenticated() throws Exception {
        // Given - Create a test zgloszenie
        Zgloszenie zgloszenie = new Zgloszenie();
        zgloszenie.setTyp("AWARIA");
        zgloszenie.setImie("Jan");
        zgloszenie.setNazwisko("Kowalski");
        zgloszenie.setTytul("Test Issue");
        zgloszenie.setOpis("Test description");
        zgloszenie.setStatus(ZgloszenieStatus.OPEN);
        zgloszenie.setDataGodzina(LocalDateTime.now());
        zgloszenie.setAutor(testUser);
        zgloszenieRepository.save(zgloszenie);

        // When & Then
        mockMvc.perform(get("/api/zgloszenia"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$", hasSize(greaterThan(0))))
                .andExpect(jsonPath("$[0].typ", is("AWARIA")))
                .andExpect(jsonPath("$[0].tytul", is("Test Issue")));
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"USER"})
    void shouldCreateZgloszenieSuccessfully() throws Exception {
        // Given
        Map<String, Object> createRequest = new HashMap<>();
        createRequest.put("typ", "AWARIA");
        createRequest.put("imie", "Anna");
        createRequest.put("nazwisko", "Nowak");
        createRequest.put("tytul", "New Issue");
        createRequest.put("opis", "New issue description");

        // When & Then
        mockMvc.perform(post("/api/zgloszenia")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.typ", is("AWARIA")))
                .andExpect(jsonPath("$.tytul", is("New Issue")))
                .andExpect(jsonPath("$.id", notNullValue()));
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"USER"})
    void shouldReturnNotFoundForNonExistentZgloszenie() throws Exception {
        mockMvc.perform(get("/api/zgloszenia/99999"))
                .andExpect(status().isNotFound());
    }

    private String getAuthToken() throws Exception {
        Map<String, String> loginRequest = new HashMap<>();
        loginRequest.put("username", testUsername);
        loginRequest.put("password", testPassword);

        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andReturn();

        String loginResponse = loginResult.getResponse().getContentAsString();
        return objectMapper.readTree(loginResponse).get("token").asText();
    }
}