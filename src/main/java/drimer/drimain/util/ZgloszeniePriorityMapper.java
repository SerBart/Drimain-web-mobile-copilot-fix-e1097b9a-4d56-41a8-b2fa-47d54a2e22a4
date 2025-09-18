package drimer.drimain.util;

import drimer.drimain.model.enums.ZgloszeniePriorytet;

public final class ZgloszeniePriorityMapper {
    private ZgloszeniePriorityMapper() {}

    public static ZgloszeniePriorytet map(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String v = raw.trim().toUpperCase();
        switch (v) {
            case "NISKI": case "LOW": return ZgloszeniePriorytet.NISKI;
            case "NORMALNY": case "NORMAL": return ZgloszeniePriorytet.NORMALNY;
            case "WYSOKI": case "HIGH": return ZgloszeniePriorytet.WYSOKI;
            case "KRYTYCZNY": case "CRITICAL": return ZgloszeniePriorytet.KRYTYCZNY;
            default:
                try { return ZgloszeniePriorytet.valueOf(v); } catch (Exception e) { return null; }
        }
    }
}