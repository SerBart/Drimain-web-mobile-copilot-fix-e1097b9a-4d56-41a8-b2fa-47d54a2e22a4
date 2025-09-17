package drimer.drimain.api.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class HarmonogramUpdateRequest {
    private LocalDate data;
    private String opis;
    private Long maszynaId;
    private Long osobaId;
    private String status;
}