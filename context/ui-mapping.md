# UI Mapping: DESIGN.md → Flutter

`DESIGN.md` is the BudgetZen design system: calm mint and sky on a near-white canvas, rounded shapes, gentle shadows. "BudgetZen" is the design system's name only; the app is still Tindahan. Every value below comes from `DESIGN.md`, except the short list under **Where the app departs from DESIGN.md**.

## Dark Mode

`DESIGN.md` has no dark theme, so `AppPalette.dark` is derived from its own families. More → Appearance offers System (default), Light and Dark, saved by `AppearanceController`.

| Token | Light | Dark |
|---|---|---|
| `background` | #FAFFFE | #1C1917 |
| `surface` | #FFFFFF | #292524 |
| `surfaceMuted` | #F5F5F4 | #44403C |
| `ink` / `onInk` | #1C1917 / #FAFAFA | #FAFAF9 / #1C1917 (snack bars and tooltips invert) |
| `stone` / `stoneDark` | #78716C / #57534E | #A8A29E / #D6D3D1 |
| `warmGray` | #A8A29E | #78716C |
| `hairline` / `inputBorder` | #E7E5E4 / #D6D3D1 | #44403C / #57534E |
| `primaryDark` | #059669 | #34D399 |
| `warningText` | #D97706 | #FBBF24 |
| `errorDark` | #DC2626 | #F87171 |

Mint, sky, amber and red fills and all tints are the same in both. The store mark uses fixed `brand…` colours, so it is the same artwork as the launch images; only the wordmark follows `ink`.

`AppColors` and `AppType` read the active palette, so they are not constants: read them in `build` and never keep one in a `static` or a field. A palette change rebuilds every element in place (`_applyAppearance` in `app.dart`), which keeps open screens and forms. A `CustomPainter` must receive its colours when constructed, so `shouldRepaint` sees the change.

Android and web show a dark launch background on a dark phone. iOS keeps the light one (`LaunchScreen.storyboard` has a single colour).

## Colours (`AppColors`)

The values below are the light palette.

| DESIGN.md | Flutter | Used for |
|---|---|---|
| Primary / Success #10B981 | `primary` | Primary buttons, focus, progress, today's chart bar |
| Hover #059669 | `primaryDark` | Pressed primary, mint text on tints, selected tab, links |
| #10B9811A / 33 / 0D | `primaryTint`, `primaryBorder`, `primaryWash` | Hero panel, active chips, icon chips; their borders; selected tiles and bands |
| Secondary / Info #38BDF8 | `info`, `infoTint`, `infoBorder` | Tips and information (`InlineNotice`), logo stripes |
| Warning #F59E0B, text #D97706 | `warning…` | Low stock, "check this" notices |
| Error #EF4444, hover #DC2626 | `error…` | Out of stock, cancelled, failed actions, destructive buttons |
| Background #FAFFFE | `background` | Scaffold |
| Surface #FFFFFF | `surface` | Cards, sheets, inputs, navigation bar |
| #F5F5F4 | `surfaceMuted` | Idle chips, segmented track, ghost pressed |
| #1C1917 / #FAFAFA | `ink`, `onInk` | Text; snack bars, tooltips and code blocks |
| Tertiary #A8A29E | `warmGray` | Inactive only. Too pale for text |
| Neutral #78716C, #57534E | `stone`, `stoneDark` | Secondary text (`textSecondary`), small text (`textSmall`) |
| #E7E5E4, #D6D3D1 | `hairline`, `inputBorder` | Dividers and card borders; input borders |

### Status

Always an **icon and a word**, never colour alone. DESIGN.md asks for no red-heavy screens, so red is kept for what failed or is blocked.

| Status | `TagTone` |
|---|---|
| In stock, paid, completed, owner | `success` |
| Low stock | `warning` |
| Out of stock, cancelled | `error` |
| Refunded, archived, category | `neutral` |

`InlineNotice` has the same idea in `NoticeTone`: `info` (default), `warning`, `error`.

## Typography (`AppType`)

Variable fonts, bundled. **They default to their lightest weight, so every style sets the `wght` axis**: build on an `AppType` style rather than setting `fontWeight` alone. `test/theme_test.dart` guards the theme slots.

| Token | Spec | Used for |
|---|---|---|
| `display` | Manrope 36 / 800 | The one big amount on a screen; Welcome headline |
| `headline` | Manrope 28 / 700 | Page titles |
| `subhead` | Manrope 20 / 600 | Section and card titles, secondary figures |
| `bodyLarge`, `body` | Nunito 18, 16 / 400 | Body text |
| `bodyStrong` | Nunito 16 / 600 | Row titles |
| `bodySmall` | Nunito 14 / 400 | Secondary lines |
| `caption`, `captionStrong` | Nunito 12 / 600, 800 | Chips, timestamps, tab labels |
| `overline` | Manrope 11 / 700, tracked | Uppercase eyebrows |
| `label`, `helper`, `chip`, `button` | From the DESIGN.md components | Input label and helper, chip text, button label |
| `code` | Source Code Pro 14 / 400 | Set-up commands |
| `tabular()` | Manrope with `tnum` | Every money and quantity figure (Nunito has no tabular figures) |

## Shape and Depth

| DESIGN.md | Flutter |
|---|---|
| Small 6 | `AppRadius.chip` |
| Medium 12 | `AppRadius.button`, `input`, `card` |
| Large 16 | `AppRadius.cardElevated`, `modal`, `sheetTop` |
| XL 24 | `AppRadius.frame` (hero panels) |
| Subtle, Medium, Large, Overlay | `AppShadows.subtle` (default cards), `medium` (raised cards), `large`, `overlay` |

Spacing: `AppSpace` on the 8 px base; `card` 20 padding, `section` 40 between major sections, `labelGap` 6; screen gutter 16; touch target 48.

## Components (`lib/ui/widgets/`)

Some class names are older than this design (`PillButton`, `TagPill`, `ChoicePill`, `SegmentedPills`). They were kept to avoid churn; they no longer draw pills.

| DESIGN.md component | Widget |
|---|---|
| Primary / Secondary / Ghost / Destructive button | `PillButton(variant: PillVariant.primary / outline / ghost / destructive)`, always Large (48 px) |
| Default / elevated card | `AppCard(tone: CardTone.plain / raised)`; `featured` and `band` are mint-tinted |
| List | `ListCard`, `ListRow` |
| Icon in a round mint chip | `IconChip`, `InitialsAvatar` |
| Status chip | `TagPill`, `StockBadge` |
| Filter chip | `ChoicePill`, `ChoiceChipRow`: small chip inside a 48 px tap area |
| Text input | `AppTextField`, `PesoField`, `QuantityField`, `SearchField`; focus and error rings come from `RingInputBorder` in `app_theme.dart` |
| Segmented control, stepper | `SegmentedPills`, `QtyStepper` |
| Empty / error / loading | `EmptyState`, `ErrorCard`, `LoadingBlocks`, `InlineNotice` |
| Brand | `AppLogo`, `AppLogoMark`, `AppWordmark` (vector, `brand.dart`) |
| Awning-topped hero | `AwningPanel`: the one main statement on a screen (Welcome, today's sales) |
| Desktop browser column | `AppViewport`: holds the app to `AppSpace.maxContentWidth` (560) |

`showConfirmDialog` and `showReasonDialog` take `destructive: true` for actions that lose something (delete expense, archive product, disable cashier, clear cart, cancel sale).

The `ThemeData` in `app_theme.dart` maps the tokens onto Material defaults (`NavigationBar`, `BottomSheet`, `Dialog`, `SnackBar`, `Tooltip`, `Switch`, `Checkbox`, `Radio`), so stock widgets follow DESIGN.md too.

## Where the app departs from DESIGN.md

| DESIGN.md | App | Why |
|---|---|---|
| Sky for links | `primaryDark` for links | Sky text on white is about 2:1, unreadable in a shop |
| Medium input 44 px | About 48 px | Touch-target rule in `AGENTS.md` |
| Stat tile card padding 20 | 16 | Two tiles side by side on a small phone |
| Hover states | Pressed states | Phone app; hover values are used for pressed |
