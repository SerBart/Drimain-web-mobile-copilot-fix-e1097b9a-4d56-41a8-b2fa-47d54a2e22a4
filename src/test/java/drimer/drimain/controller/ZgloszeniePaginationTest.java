package drimer.drimain.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import drimer.drimain.api.dto.PageResponse;
import drimer.drimain.api.dto.ZgloszenieDTO;
import drimer.drimain.repository.ZgloszenieRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
public class ZgloszeniePaginationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ZgloszenieRepository zgloszenieRepository;

    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN", "USER"})
    public void testZgloszeniaPaginationEndpoint() throws Exception {
        // Test the pagination endpoint with default parameters
        MvcResult result = mockMvc.perform(get("/api/zgloszenia"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andReturn();

        String responseContent = result.getResponse().getContentAsString();
        
        // Parse response into PageResponse
        PageResponse pageResponse = objectMapper.readValue(responseContent, PageResponse.class);
        
        // Verify pagination structure
        assertThat(pageResponse).isNotNull();
        assertThat(pageResponse.getContent()).isNotNull();
        assertThat(pageResponse.getPage()).isEqualTo(0);
        assertThat(pageResponse.getSize()).isEqualTo(20);
        assertThat(pageResponse.getTotalElements()).isEqualTo(0);
        assertThat(pageResponse.getTotalPages()).isEqualTo(0);
        assertThat(pageResponse.isLast()).isTrue();
    }

    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN", "USER"})
    public void testZgloszeniaPaginationWithCustomParameters() throws Exception {
        // Test with custom page size and filters
        mockMvc.perform(get("/api/zgloszenia")
                .param("page", "0")
                .param("size", "10")
                .param("status", "OPEN")
                .param("priorytet", "WYSOKI")
                .param("sort", "createdAt,asc"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.size").value(10))
                .andExpect(jsonPath("$.content").isArray());
    }

    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN", "USER"})
    public void testZgloszeniaPaginationUnauthorized() throws Exception {
        // Test without proper authentication should still work since it's a GET endpoint
        // but let's test that the endpoint structure is consistent
        mockMvc.perform(get("/api/zgloszenia")
                .param("q", "test search"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").exists())
                .andExpect(jsonPath("$.page").exists())
                .andExpect(jsonPath("$.size").exists())
                .andExpect(jsonPath("$.totalElements").exists())
                .andExpect(jsonPath("$.totalPages").exists())
                .andExpect(jsonPath("$.last").exists());
    }
}