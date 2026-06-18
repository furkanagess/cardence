# 10 — Ana Kabuk: Alt Navigasyon (Referans)

**Dosya:** `lib/features/shell/presentation/pages/main_shell_page.dart`  
**Not:** Bileşen referansı; 3 sekme arasında tutarlılık için kullanın.

---

## Stitch prompt

```
[GLOBAL DESIGN SYSTEM]

Screen: Main Shell — Bottom Navigation only (overlay reference)

Show 3-tab bottom nav pill floating 16px above home indicator.
Tab 0 active (saved cards): people_outline icon on navy pill segment.
Tabs 1-2 inactive gray.

Optional: show faint page content behind — either card stack or list header.
This frame is for nav component consistency across tabs 0/1/2.
```

## Sekme eşlemesi

| Index | İkon | Ekran | AppBar başlığı |
|-------|------|-------|----------------|
| 0 | `people_outline_rounded` | Kayıtlı kartlar | *(yok — özel toolbar)* |
| 1 | `event_note_rounded` | Etkinlik grupları | Etkinlik grupları |
| 2 | `person_rounded` | Profil | Profil |

AppBar aksiyonları: Tüm sekmelerde **Ayarlar** (⚙); sekme 1'de ek **+** (grup oluştur).
