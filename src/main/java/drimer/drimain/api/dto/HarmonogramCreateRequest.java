package drimer.drimain.api.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class HarmonogramCreateRequest {
    private LocalDate data;
    private String opis;
    private Long maszynaId;
    private Long osobaId;
    private String status;
}