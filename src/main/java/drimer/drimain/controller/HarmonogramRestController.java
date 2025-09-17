package drimer.drimain.controller;

import drimer.drimain.api.dto.*;
import drimer.drimain.model.Harmonogram;
import drimer.drimain.model.enums.StatusHarmonogramu;
import drimer.drimain.repository.HarmonogramRepository;
import drimer.drimain.repository.MaszynaRepository;
import drimer.drimain.repository.OsobaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/harmonogramy")
@RequiredArgsConstructor
public class HarmonogramRestController {

    private final HarmonogramRepository harmonogramRepository;
    private final MaszynaRepository maszynaRepository;
    private final OsobaRepository osobaRepository;

    @GetMapping
    public List<HarmonogramDTO> list(@RequestParam Optional<Integer> year,
                                     @RequestParam Optional<Integer> month,
                                     @RequestParam Optional<String> status) {
        return harmonogramRepository.findAll().stream()
                .filter(h -> year.map(y -> h.getData() != null && h.getData().getYear() == y).orElse(true))
                .filter(h -> month.map(m -> h.getData() != null && h.getData().getMonthValue() == m).orElse(true))
                .filter(h -> status.map(s -> h.getStatus() != null && h.getStatus().name().equalsIgnoreCase(s)).orElse(true))
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public HarmonogramDTO get(@PathVariable Long id) {
        Harmonogram h = harmonogramRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Harmonogram not found"));
        return toDto(h);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public HarmonogramDTO create(@RequestBody HarmonogramCreateRequest req) {
        Harmonogram h = new Harmonogram();
        h.setData(req.getData());
        h.setOpis(req.getOpis());
        
        if (req.getMaszynaId() != null) {
            h.setMaszyna(maszynaRepository.findById(req.getMaszynaId())
                    .orElseThrow(() -> new IllegalArgumentException("Maszyna not found")));
        }
        
        if (req.getOsobaId() != null) {
            h.setOsoba(osobaRepository.findById(req.getOsobaId())
                    .orElseThrow(() -> new IllegalArgumentException("Osoba not found")));
        }
        
        if (req.getStatus() != null) {
            try {
                h.setStatus(StatusHarmonogramu.valueOf(req.getStatus().toUpperCase()));
            } catch (IllegalArgumentException e) {
                h.setStatus(StatusHarmonogramu.PLANOWANE);
            }
        }
        
        harmonogramRepository.save(h);
        return toDto(h);
    }

    @PutMapping("/{id}")
    public HarmonogramDTO update(@PathVariable Long id, @RequestBody HarmonogramUpdateRequest req) {
        Harmonogram h = harmonogramRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Harmonogram not found"));
        
        if (req.getData() != null) h.setData(req.getData());
        if (req.getOpis() != null) h.setOpis(req.getOpis());
        
        if (req.getMaszynaId() != null) {
            h.setMaszyna(maszynaRepository.findById(req.getMaszynaId())
                    .orElseThrow(() -> new IllegalArgumentException("Maszyna not found")));
        }
        
        if (req.getOsobaId() != null) {
            h.setOsoba(osobaRepository.findById(req.getOsobaId())
                    .orElseThrow(() -> new IllegalArgumentException("Osoba not found")));
        }
        
        if (req.getStatus() != null) {
            try {
                h.setStatus(StatusHarmonogramu.valueOf(req.getStatus().toUpperCase()));
            } catch (IllegalArgumentException e) {
                // Keep existing status if invalid
            }
        }
        
        harmonogramRepository.save(h);
        return toDto(h);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        if (!harmonogramRepository.existsById(id)) {
            throw new IllegalArgumentException("Harmonogram not found");
        }
        harmonogramRepository.deleteById(id);
    }

    private HarmonogramDTO toDto(Harmonogram h) {
        HarmonogramDTO dto = new HarmonogramDTO();
        dto.setId(h.getId());
        dto.setData(h.getData());
        dto.setOpis(h.getOpis());
        dto.setStatus(h.getStatus() != null ? h.getStatus().name() : null);
        
        if (h.getMaszyna() != null) {
            SimpleMaszynaDTO maszyna = new SimpleMaszynaDTO();
            maszyna.setId(h.getMaszyna().getId());
            maszyna.setNazwa(h.getMaszyna().getNazwa());
            dto.setMaszyna(maszyna);
        }
        
        if (h.getOsoba() != null) {
            SimpleOsobaDTO osoba = new SimpleOsobaDTO();
            osoba.setId(h.getOsoba().getId());
            osoba.setImieNazwisko(h.getOsoba().getImieNazwisko());
            dto.setOsoba(osoba);
        }
        
        return dto;
    }
}