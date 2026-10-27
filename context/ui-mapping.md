# UI Mapping: DESIGN.md → Flutter

`DESIGN.md` describes two tracks. The app uses the **light transactional track** (cream canvas, aloe and pistachio greens, black pills, Inter) on every screen except **Welcome**, which uses the **cinematic black canvas**. No property below is invented; each comes from `DESIGN.md`.

## Colours (`AppColors`)

| DESIGN.md | Flutter | Used for |
|---|---|---|
| `canvas-cream` #fbfbf5 | `canvasCream` | Scaffold background on all light screens |
| `canvas-light` #ffffff | `canvasLight` | Cards, sheets, inputs |
| `primary` / `ink` #000000 | `primary`, `ink` | Primary pill buttons, text, active nav, "out of stock" pill |
| `on-primary` #ffffff | `onPrimary` | Text on black |
| `aloe-10` #c1fbd4 | `aloe10` | Featured cards (today's sales), "in stock" / positive pills, selected chips |
| `pistachio-10` #d4f9e0 | `pistachio10` | Bands (summary strip, profit preview, offline notice) |
| `shade-30…70` | `shade30…shade70` | Hairlines, secondary text (`shade-50`), small text (`shade-60`), pressed primary (`shade-70`), "low stock" pill (`shade-30`) |
| `hairline-light` #e4e4e7 | `hairlineLight` | Card and input borders, dividers |
| `canvas-night`, `surface-elevated-dark` | `canvasNight`, `surfaceElevatedDark` | Welcome screen only |

### Status without red or amber

`DESIGN.md` defines no warning or error colours, so status always pairs an **icon and a word** with a neutral or brand fill:

| Status | Pill |
|---|---|
| In stock | aloe fill, check icon, "May stock" |
| Low | shade-30 fill, trending-down icon, "Paubos na" |
| Out | ink fill, white text, block icon, "Ubos na" |
| Error message | `ErrorCard`: neutral card, icon, plain-language text and a retry button |

## Typography (`AppType`)

Inter variable (bundled). `ss03` on every style. Display styles use `opsz` 32. Weights 330 / 420 / 550 from DESIGN.md.

| Token | Size / weight | Used for |
|---|---|---|
| `displayHero` | 56 / 330 | Welcome headline |
| `displayMd` | 48 / 330 | Big money figures: dashboard sales, checkout total, utang balances, product price |
| `displayMobile` | 36 / 330 | Page headers |
| `headingXl…headingSm` | DESIGN.md heading scale | Section and card titles |
| `bodyLg` | 18 / 550 | Lead paragraphs |
| `bodyMd` | 16 / 420 | Body text |
| `bodyStrong` | 16 / 550 | Emphasised rows |
| `caption`, `micro` | small scale | Secondary lines, timestamps |
| `eyebrowCap` | 12 / 400, tracked | Uppercase section eyebrows |
| `tabular()` | adds `tnum` | Every money and quantity figure |

## Shape and Depth

| DESIGN.md | Flutter |
|---|---|
| Card radius 12 | `AppRadius.card` |
| Input radius 8 | `AppRadius.input` |
| Pill buttons | `AppRadius.pill` (9999) |
| Frame / sheet 20 | `AppRadius.frame`, `AppRadius.sheetTop` |
| Level-3 stacked shadow | `AppShadows.level3` (`AppCard` raised tone) |
| Level-4 | `AppShadows.level4` (reserved for overlays) |

Spacing scale: `AppSpace` 2 · 4 · 8 · 12 · 16 · 24 · 32 · 64; screen gutter 16; touch target 48.

## Components (`lib/ui/widgets/`)

| DESIGN.md component | Widget |
|---|---|
| Black pill CTA | `PillButton(variant: PillVariant.primary)` |
| Outline pill | `PillButton(variant: PillVariant.outline)` |
| Aloe pill | `PillButton(variant: PillVariant.aloe)` |
| Text button | `PillButton(variant: PillVariant.ghost)` |
| White-stroked pill on black | `PillButton(variant: PillVariant.outlineOnDark)` (Welcome) |
| Plain / featured / band card | `AppCard(tone: CardTone.plain / featured / band / raised)` |
| List card with rows | `ListCard`, `ListRow` |
| Tag pill | `TagPill`, `StockBadge` |
| Input | `AppTextField`, `PesoField`, `QuantityField`, `SearchField` |
| Chips / segmented control | `ChoiceChipRow`, `ChoicePill`, `SegmentedPills` |
| Stepper | `QtyStepper` |
| Empty / error / loading | `EmptyState`, `ErrorCard`, `LoadingBlocks`, `InlineNotice` |

The `ThemeData` built in `app_theme.dart` maps these tokens onto Material defaults (`NavigationBar`, `BottomSheet`, `Dialog`, `SnackBar`, `Switch`) so stock Material widgets also follow DESIGN.md.
