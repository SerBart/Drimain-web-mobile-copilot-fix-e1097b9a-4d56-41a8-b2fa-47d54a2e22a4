package drimer.drimain.controller;

import drimer.drimain.api.dto.*;
import drimer.drimain.api.mapper.ZgloszenieMapper;
import drimer.drimain.model.Zgloszenie;
import drimer.drimain.model.enums.ZgloszenieStatus;
import drimer.drimain.model.enums.ZgloszeniePriorytet;
import drimer.drimain.repository.ZgloszenieRepository;
import drimer.drimain.service.ZgloszenieCommandService;
import drimer.drimain.util.ZgloszenieStatusMapper;
import drimer.drimain.util.ZgloszeniePriorityMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/zgloszenia")
@RequiredArgsConstructor
public class ZgloszenieRestController {

    private final ZgloszenieRepository zgloszenieRepository;
    private final ZgloszenieCommandService commandService;

    @GetMapping
    public PageResponse<ZgloszenieDTO> list(@RequestParam(required = false) String status,
                                           @RequestParam(required = false) String priorytet,
                                           @RequestParam(required = false) String typ,
                                           @RequestParam(required = false) Long dzial,
                                           @RequestParam(required = false) String q,
                                           @RequestParam(defaultValue = "0") int page,
                                           @RequestParam(defaultValue = "20") int size,
                                           @RequestParam(defaultValue = "createdAt,desc") String sort) {

        // Parse sorting parameters - handle "field,direction" format
        Sort sortObj;
        if (sort.contains(",")) {
            String[] sortParts = sort.split(",");
            String field = sortParts[0].trim();
            Sort.Direction dir = sortParts.length > 1 && sortParts[1].trim().equalsIgnoreCase("asc") 
                ? Sort.Direction.ASC : Sort.Direction.DESC;
            sortObj = Sort.by(dir, field);
        } else {
            // Default to descending if no direction specified
            sortObj = Sort.by(Sort.Direction.DESC, sort);
        }

        Pageable pageable = PageRequest.of(page, size, sortObj);

        // Map status parameter
        ZgloszenieStatus statusEnum = null;
        if (status != null && !status.isBlank()) {
            statusEnum = ZgloszenieStatusMapper.map(status);
        }

        // Map priority parameter
        ZgloszeniePriorytet prioryteTEnum = null;
        if (priorytet != null && !priorytet.isBlank()) {
            prioryteTEnum = ZgloszeniePriorityMapper.map(priorytet);
        }

        // Call repository with filters and pagination
        Page<Zgloszenie> pageData = zgloszenieRepository.findWithFilters(
            statusEnum,
            prioryteTEnum, 
            typ,
            dzial,
            null, // autorId - can be added later if needed
            q,
            pageable
        );

        // Convert to DTO and wrap in PageResponse
        Page<ZgloszenieDTO> dtoPage = pageData.map(ZgloszenieMapper::toDto);
        return PageResponse.of(dtoPage);
    }

    @GetMapping("/{id}")
    public ZgloszenieDTO get(@PathVariable Long id) {
        Zgloszenie z = zgloszenieRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Zgloszenie not found"));
        return ZgloszenieMapper.toDto(z);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ZgloszenieDTO create(@RequestBody ZgloszenieCreateRequest req, Authentication authentication) {
        Zgloszenie z = commandService.create(req, authentication);
        return ZgloszenieMapper.toDto(z);
    }

    @PutMapping("/{id}")
    public ZgloszenieDTO update(@PathVariable Long id, @RequestBody ZgloszenieUpdateRequest req, 
                                Authentication authentication) {
        // Check if user has edit permissions (ADMIN or BIURO roles)
        if (!hasEditPermissions(authentication)) {
            throw new SecurityException("Access denied. Admin or Biuro role required.");
        }
        
        Zgloszenie z = commandService.update(id, req, authentication);
        return ZgloszenieMapper.toDto(z);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id, Authentication authentication) {
        // Check if user has delete permissions (ADMIN or BIURO roles)
        if (!hasEditPermissions(authentication)) {
            throw new SecurityException("Access denied. Admin or Biuro role required.");
        }
        commandService.delete(id, authentication);
    }
    
    /**
     * Check if the authenticated user has edit/delete permissions (ADMIN or BIURO role)
     */
    private boolean hasEditPermissions(Authentication authentication) {
        if (authentication == null) return false;
        return authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN") || 
                              a.getAuthority().equals("ROLE_BIURO"));
    }
}