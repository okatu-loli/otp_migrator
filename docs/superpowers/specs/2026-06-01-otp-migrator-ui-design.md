# OTP Migrator — UI Design System

- Date: 2026-06-01
- Status: design tokens locked (Task 0). UI code is built against the API in `lib/ui/theme/app_theme.dart`.
- Scope: visual direction + Flutter Material 3 theme tokens for a cross-platform (desktop / mobile / web) security utility.

---

## 1. Visual direction — "Terminal Ledger"

The app decodes and exposes raw OTP secrets. The product must read as **a precise instrument for handling sensitive credentials**, closer to a hardware-security-key companion or a well-built CLI admin panel than a consumer app. The emotional target is **calm, credible, legible, dense-but-orderly** — the user should trust it with their 2FA seeds.

Concept: a quiet *ledger* rendered on a *terminal*. Flat slate surfaces, hairline dividers, near-zero elevation, monospaced treatment for the data that actually matters (secrets, URLs, metadata), and one disciplined accent color that means "verified / safe".

### What AI-cliché we are deliberately rejecting
- **NO purple→blue (or indigo→violet) gradients.** The single accent is a muted, desaturated teal-green — an instrument color, never a marketing gradient.
- **NO centered hero card floating on a gradient background.** Layout is an edge-to-edge working surface (two real columns on desktop), not a landing page.
- **NO glassmorphism / frosted blur / neon glow / drop-shadow halos.** Surfaces are opaque and separated by hairline 1px borders and tonal background steps, not by blur or glow.
- **NO oversized rounded "pill everything" bubbliness.** Radii are restrained (8–12px), corners feel engineered, not toy-like.
- **NO default Material deep-purple seed and NO Inter/Roboto-as-statement.** Type is the platform humanist sans for chrome + true monospace for data; the personality comes from hierarchy and the mono/sans contrast, not a trendy display face.

### Signature detail (the memorable thing)
Secrets, otpauth URLs, and the metadata line (`TOTP · SHA1 · 6 digits`) are set in **monospace inside a tonal "code chip" surface** with a hairline border. The app visibly treats credentials as *data under glass*, which is exactly the trust signal a security tool needs.

---

## 2. Color palette

Neutrals are slate-tinted (a hair of cool blue-grey), not pure grey — this reads as "engineered" rather than sterile. The accent is the only chromatic role used for primary action / focus / selection. Semantic colors (success/warning/error/info) are reserved for status only, never decoration.

### Accent (brand)
A muted teal-green. Desaturated enough to feel professional; green-leaning so it reads as "verified / secure".

| Role | Light | Dark |
|---|---|---|
| Accent / primary | `#0F7B6C` | `#3DBFA8` |
| On accent | `#FFFFFF` | `#06241F` |
| Accent container | `#CDEAE3` | `#11433A` |
| On accent container | `#053A32` | `#BFEFE4` |

### Neutral surfaces & text

| Role | Light | Dark |
|---|---|---|
| Background (app) | `#F7F8F8` | `#0E1213` |
| Surface (cards/panels) | `#FFFFFF` | `#161B1D` |
| Surface variant (code chip / inset) | `#EEF1F1` | `#1E2528` |
| Surface container high (dialogs/menus) | `#FFFFFF` | `#1B2123` |
| Outline (hairline border) | `#D6DBDB` | `#2C3538` |
| Outline variant (subtle divider) | `#E4E8E8` | `#222A2D` |
| Text primary (on surface) | `#15201F` | `#E6ECEB` |
| Text secondary (on surface variant) | `#5A6664` | `#9AA8A5` |

### Secondary (neutral chips / non-primary controls)

| Role | Light | Dark |
|---|---|---|
| Secondary | `#4A5D59` | `#B6C6C2` |
| On secondary | `#FFFFFF` | `#1F2B29` |
| Secondary container | `#E2E9E7` | `#2A3735` |
| On secondary container | `#27302E` | `#D6E2DF` |

### Semantic status colors (exposed as `AppSemanticColors` ThemeExtension)

| Role | Light | Dark |
|---|---|---|
| Success | `#0F7B5A` | `#34C98C` |
| On success container | `#053524` | `#BFF0DC` |
| Success container | `#CDEEDF` | `#0E3B2A` |
| Warning | `#9A6500` | `#E0A93B` |
| On warning container | `#3A2600` | `#F4E3BD` |
| Warning container | `#F6E6C4` | `#3E2E08` |
| Error | `#B3261E` | `#F2796E` |
| On error container | `#410E0B` | `#F6D6D2` |
| Error container | `#F6D7D4` | `#492220` |
| Info | `#1B5FA8` | `#6FB3F2` |
| On info container | `#062744` | `#CFE3F8` |
| Info container | `#D3E3F6` | `#0E3354` |

Rationale: success deliberately shares the green family with the accent (the whole product is "green = good"), while warning/error/info stay clearly distinct. Error stays a real Material-grade red so destructive states are unmistakable.

---

## 3. Typography

**Font strategy: system + true monospace, zero new dependencies.**
- UI chrome / prose → the platform humanist sans (San Francisco on Apple, Roboto on Android, Segoe/UI default on Windows/Linux/Web). Expressed by leaving `fontFamily` null on the sans roles so Flutter falls through to the platform default.
- Data (secrets, URLs, metadata, counters) → `monospace`, Flutter's generic family that maps to SF Mono / Roboto Mono / Consolas / DejaVu Sans Mono per platform.

This gives a deliberate **sans-for-chrome / mono-for-data** contrast — the source of the design's character — without bundling or downloading fonts. The mono family name is exported as `AppTheme.monoFontFamily` so widgets can opt in for code chips.

### Type scale (Material 3 roles, tuned)
Tightened tracking on large sizes, comfortable line height on body. Weights stay in the 400–600 range; we avoid heavy display weights (this isn't a marketing page).

| Role | Size / line-height / weight / spacing | Usage |
|---|---|---|
| `headlineSmall` | 24 / 1.25 / w600 / -0.2 | Page / panel title |
| `titleLarge` | 20 / 1.3 / w600 / -0.1 | Section headers, dialog titles |
| `titleMedium` | 16 / 1.4 / w600 / 0 | Card title (issuer · name) |
| `bodyLarge` | 15 / 1.45 / w400 / 0 | Primary body |
| `bodyMedium` | 14 / 1.45 / w400 / 0 | Default body, list text |
| `bodySmall` | 12.5 / 1.4 / w400 / 0.1 | Helper / captions |
| `labelLarge` | 14 / 1.2 / w600 / 0.2 | Buttons |
| `labelMedium` | 12 / 1.2 / w500 / 0.4 | Tabs, small controls |
| `labelSmall` | 11 / 1.2 / w500 / 0.5 (UPPERCASE in use) | Metadata pills, eyebrow labels |

**Mono usage** (applied per-widget via `monoFontFamily`, sizes borrow from body roles): secret strings at ~13.5 mono w500 with slight letter spacing; metadata line at 12 mono; URLs at 13 mono.

---

## 4. Spacing & radius scale

8pt-based, with a 4pt half-step for dense controls. Exported as `AppSpacing`.

| Token | px | Typical use |
|---|---|---|
| `xxs` | 2 | icon/text nudge |
| `xs` | 4 | chip inner gap, dense vertical |
| `sm` | 8 | control padding, gap between related items |
| `md` | 12 | card inner padding (compact), list item gap |
| `lg` | 16 | card padding, default content gutter |
| `xl` | 24 | panel padding, column gutter |
| `xxl` | 32 | page margins on desktop, major section gaps |
| `xxxl` | 48 | empty-state breathing room |

Radii (`AppRadii`): `chip` 6, `card` 12, `control` 8, `dialog` 16, `pill` 999.
Border (`AppBorders.hairline`): 1.0px using the `outline` color. This single hairline does almost all the separation work — no shadows by default.

---

## 5. Elevation & border treatment

- **Flat by default.** `cardTheme` elevation 0, surfaces separated by `outline`/`outlineVariant` hairlines and the tonal background→surface step.
- Dialogs and menus get a *minimal* real shadow (elevation 2–3) only because they float above content; everything in-page is elevation 0.
- Dark mode does **not** lighten surfaces via Material's tonal overlay alone — we set explicit `surface` / `surfaceContainerHigh` hex steps so panels read as deliberate slate layers, not auto-tinted purple-grey.
- Focus/selection uses the accent at low opacity for fills and full accent for the 1–2px focus ring.

---

## 6. Component specs

### Account card (key screen 2)
- Surface `surface`, radius `card` (12), 1px `outline` border, elevation 0.
- Padding `lg` (16). Layout: leading monogram/issuer avatar (40px, `secondaryContainer` fill, rounded `control`), then a column:
  - **Title row:** `issuer` in `titleMedium` w600, then a hairline middot, then `name` in `bodyMedium` `onSurfaceVariant`. Truncates with ellipsis.
  - **Metadata line:** mono `labelSmall`-style pills / inline text — `TOTP · SHA1 · 6 digits` (`onSurfaceVariant`). Type (TOTP/HOTP) may be a small `secondaryContainer` pill (radius `chip`).
  - **Secret row:** a full-width "code chip" — `surfaceVariant` fill, radius `chip`, hairline border, `monospace` text, with a trailing copy affordance. Long-press / hover reveals copy.
- **Trailing:** an icon button (`Icons.qr_code_2`) to open the QR preview dialog; tooltip "Show QR".
- Hover (desktop/web): border shifts to accent at ~40% and background nudges to `surfaceVariant` — no scale, no shadow.

### Buttons
- Primary action → `FilledButton`, accent fill, `onPrimary` text, radius `control` (8), height 40, `labelLarge`.
- Secondary → `OutlinedButton`, 1px `outline`, accent text on hover.
- Tertiary / inline → `TextButton`, accent text.
- Icon buttons → 40px hit target, `onSurfaceVariant` icon, accent on hover/focus.

### List items / source groups
- Group header: `labelSmall` uppercase eyebrow (`onSurfaceVariant`) + count, with an `outlineVariant` divider beneath.
- Items separated by `outlineVariant` hairlines (not cards inside cards) to control density on long lists.

### Dialogs (QR preview + Export)
- `surfaceContainerHigh`, radius `dialog` (16), elevation 3, max width ~420 (QR) / ~480 (export).
- **QR preview:** centered QR on a `surface` plate with `lg` padding and hairline border (quiet-zone honored), caption below in mono showing the otpauth URL (selectable, truncated with "copy"), title = issuer · name. Close + "Copy URL" actions.
- **Export dialog:** title "Export accounts", a `RadioListTile` group of formats (JSON / CSV / QR images / Text URLs / URL). Each row: format name (`titleMedium`-ish `bodyLarge` w500) + one-line mono/`bodySmall` description of the output. Selected row tinted with accent container. Footer: scope summary ("N accounts" / "Merged"), `Cancel` (text) + `Export` (filled).

### Inputs
- Text fields (paste-URL): `surfaceVariant` fill, no underline, 1px `outline`, accent 2px on focus, radius `control`. Paste field uses `monospace`.
- Switches (Merge-export toggle): accent thumb/track when on.

---

## 7. Responsive adaptation

Single breakpoint constant `AppBreakpoints.expanded = 900`.

- **Wide (≥ 900px — desktop / large web / tablet landscape):** two-column working surface. Left column (~40%, min ~360px) = import area (drag-drop zone, paste field, camera entry, merge toggle). Right column (~60%) = scrollable results (source groups → account cards). Column gutter `xl` (24), page margin `xxl` (32). No max-width "centered page" — the tool fills the window like an editor.
- **Narrow (< 900px — phones / small web):** the two areas collapse into a **two-tab** layout ("Import" / "Results") via a `TabBar`, single column, page margin `lg` (16). Account cards go full-bleed width; the code chip wraps/scrolls horizontally rather than truncating the secret.
- Touch targets stay ≥ 44px on all platforms; hover affordances are additive (never required) so the same widgets work for mouse and touch.
- Dialogs become near-full-width sheets under ~480px.

---

## 8. Public API contract (depended on by later UI tasks)

Exposed from `lib/ui/theme/app_theme.dart`:

- `AppTheme.light` / `AppTheme.dark` → `ThemeData` (Material 3).
- `AppTheme.monoFontFamily` → `String` for code/secret widgets.
- `AppSpacing.{xxs,xs,sm,md,lg,xl,xxl,xxxl}` → `double`.
- `AppRadii.{chip,control,card,dialog,pill}` → `double`.
- `AppBorders.hairline` → `double` (1.0).
- `AppBreakpoints.expanded` → `double` (900).
- `AppSemanticColors` `ThemeExtension` with `success/onSuccess/successContainer/onSuccessContainer`, `warning/onWarning/warningContainer/onWarningContainer`, `error...`, `info...`; read via `Theme.of(context).extension<AppSemanticColors>()!`. Convenience getter `context`-free: use `theme.extension<AppSemanticColors>()`.

These names are stable; UI tasks should consume them rather than hard-coding colors.
