# 27 — Onay Diyaloğu (Ortak Bileşen)

**Dosya:** `lib/core/widgets/molecules/cardence_confirm_dialog.dart`  
**Kullanım:** Çıkış, silme, değişiklikleri atma

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Component: Confirmation Dialog (modal, 12px radius)

- Optional icon top center in circle (warning red for delete, logout icon for exit)
- Title semibold center
- Message body gray center, 2-3 lines
- Actions row: "İptal" text left | "Onayla" / "Çıkış yap" / "Sil" destructive or primary right
- Examples: discard changes, delete card, delete group, logout
```

## Kullanım senaryoları

| Senaryo | Başlık | Onay |
|---------|--------|------|
| Çıkış yap | Çıkış yap | Çıkış yap (destructive) |
| Kartı sil | Kartı sil | Sil |
| Grubu sil | Bu grubu sil | Sil |
| Kaydedilmemiş değişiklik | Değişiklikleri at | At |
