package drimer.drimain.controller;

import drimer.drimain.api.dto.*;
import drimer.drimain.model.*;
import drimer.drimain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminRestController {

    private final DzialRepository dzialRepository;
    private final MaszynaRepository maszynaRepository;
    private final OsobaRepository osobaRepository;
    private final UserRepository userRepository;

    // Działy management
    @GetMapping("/dzialy")
    public List<DzialDTO> getDzialy() {
        return dzialRepository.findAll().stream()
                .map(this::toDzialDto)
                .collect(Collectors.toList());
    }

    @PostMapping("/dzialy")
    @ResponseStatus(HttpStatus.CREATED)
    public DzialDTO createDzial(@RequestBody DzialDTO dto) {
        Dzial dzial = new Dzial();
        dzial.setNazwa(dto.getNazwa());
        dzialRepository.save(dzial);
        return toDzialDto(dzial);
    }

    @PutMapping("/dzialy/{id}")
    public DzialDTO updateDzial(@PathVariable Long id, @RequestBody DzialDTO dto) {
        Dzial dzial = dzialRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Dzial not found"));
        dzial.setNazwa(dto.getNazwa());
        dzialRepository.save(dzial);
        return toDzialDto(dzial);
    }

    @DeleteMapping("/dzialy/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDzial(@PathVariable Long id) {
        if (!dzialRepository.existsById(id)) {
            throw new IllegalArgumentException("Dzial not found");
        }
        dzialRepository.deleteById(id);
    }

    // Maszyny management
    @GetMapping("/maszyny")
    public List<MaszynaDTO> getMaszyny() {
        return maszynaRepository.findAll().stream()
                .map(this::toMaszynaDto)
                .collect(Collectors.toList());
    }

    @PostMapping("/maszyny")
    @ResponseStatus(HttpStatus.CREATED)
    public MaszynaDTO createMaszyna(@RequestBody MaszynaDTO dto) {
        Maszyna maszyna = new Maszyna();
        maszyna.setNazwa(dto.getNazwa());
        if (dto.getDzial() != null && dto.getDzial().getId() != null) {
            Dzial dzial = dzialRepository.findById(dto.getDzial().getId())
                    .orElseThrow(() -> new IllegalArgumentException("Dzial not found"));
            maszyna.setDzial(dzial);
        }
        maszynaRepository.save(maszyna);
        return toMaszynaDto(maszyna);
    }

    @PutMapping("/maszyny/{id}")
    public MaszynaDTO updateMaszyna(@PathVariable Long id, @RequestBody MaszynaDTO dto) {
        Maszyna maszyna = maszynaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Maszyna not found"));
        maszyna.setNazwa(dto.getNazwa());
        if (dto.getDzial() != null && dto.getDzial().getId() != null) {
            Dzial dzial = dzialRepository.findById(dto.getDzial().getId())
                    .orElseThrow(() -> new IllegalArgumentException("Dzial not found"));
            maszyna.setDzial(dzial);
        }
        maszynaRepository.save(maszyna);
        return toMaszynaDto(maszyna);
    }

    @DeleteMapping("/maszyny/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteMaszyna(@PathVariable Long id) {
        if (!maszynaRepository.existsById(id)) {
            throw new IllegalArgumentException("Maszyna not found");
        }
        maszynaRepository.deleteById(id);
    }

    // Osoby management
    @GetMapping("/osoby")
    public List<OsobaDTO> getOsoby() {
        return osobaRepository.findAll().stream()
                .map(this::toOsobaDto)
                .collect(Collectors.toList());
    }

    @PostMapping("/osoby")
    @ResponseStatus(HttpStatus.CREATED)
    public OsobaDTO createOsoba(@RequestBody OsobaDTO dto) {
        Osoba osoba = new Osoba();
        osoba.setLogin(dto.getLogin());
        osoba.setImieNazwisko(dto.getImieNazwisko());
        osoba.setRola(dto.getRola());
        // haslo should be handled separately for security
        osobaRepository.save(osoba);
        return toOsobaDto(osoba);
    }

    @PutMapping("/osoby/{id}")
    public OsobaDTO updateOsoba(@PathVariable Long id, @RequestBody OsobaDTO dto) {
        Osoba osoba = osobaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Osoba not found"));
        if (dto.getLogin() != null) osoba.setLogin(dto.getLogin());
        if (dto.getImieNazwisko() != null) osoba.setImieNazwisko(dto.getImieNazwisko());
        if (dto.getRola() != null) osoba.setRola(dto.getRola());
        osobaRepository.save(osoba);
        return toOsobaDto(osoba);
    }

    @DeleteMapping("/osoby/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteOsoba(@PathVariable Long id) {
        if (!osobaRepository.existsById(id)) {
            throw new IllegalArgumentException("Osoba not found");
        }
        osobaRepository.deleteById(id);
    }

    // Users management
    @GetMapping("/users")
    public List<UserDTO> getUsers() {
        return userRepository.findAll().stream()
                .map(this::toUserDto)
                .collect(Collectors.toList());
    }

    // Helper methods
    private DzialDTO toDzialDto(Dzial dzial) {
        DzialDTO dto = new DzialDTO();
        dto.setId(dzial.getId());
        dto.setNazwa(dzial.getNazwa());
        return dto;
    }

    private MaszynaDTO toMaszynaDto(Maszyna maszyna) {
        MaszynaDTO dto = new MaszynaDTO();
        dto.setId(maszyna.getId());
        dto.setNazwa(maszyna.getNazwa());
        if (maszyna.getDzial() != null) {
            dto.setDzial(toDzialDto(maszyna.getDzial()));
        }
        return dto;
    }

    private OsobaDTO toOsobaDto(Osoba osoba) {
        OsobaDTO dto = new OsobaDTO();
        dto.setId(osoba.getId());
        dto.setLogin(osoba.getLogin());
        dto.setImieNazwisko(osoba.getImieNazwisko());
        dto.setRola(osoba.getRola());
        return dto;
    }

    private UserDTO toUserDto(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        // email not available in User model
        return dto;
    }
}