package drimer.drimain.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry reg) {
        reg.addMapping("/api/**")
                // TODO: In production, narrow down allowed origins to specific domains
                .allowedOrigins(
                        "http://localhost:5173",     // Flutter web dev server
                        "http://localhost:4200",     // Angular dev server (if used)
                        "http://127.0.0.1:5173",     // Alternative localhost
                        "http://10.0.2.2:8080",      // Android emulator
                        "http://localhost:8080",     // Spring Boot app
                        "http://10.0.2.2:5173"       // Android emulator Flutter
                )
                .allowedMethods("GET","POST","PUT","PATCH","DELETE","OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}