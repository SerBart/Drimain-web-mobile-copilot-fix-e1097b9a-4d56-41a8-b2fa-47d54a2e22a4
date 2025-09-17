package drimer.drimain.api.dto;

import lombok.Data;

@Data
public class UserDTO {
    private Long id;
    private String username;
    // roles will be included as collection if needed
    // password excluded for security
}