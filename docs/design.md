# RemediBook Design System (Source of Truth)

## 1. Cashmere-First Color Palette
The "Quiet Luxury" aesthetic is built on warm, natural tones and deep, trustworthy accents.

| Token | Hex | Role |
|---|---|---|
| **bgPrimary** | `#F4EDE3` | Cashmere (Main Background) |
| **bgSecondary** | `#F2F0E6` | Warm Limestone (Surface/Card Bg) |
| **brandPrimary** | `#1F4E5F` | Deep Teal (Brand Identity, Primary Actions) |
| **accentGold** | `#D4A373` | Ember Gold (Highlights, CTAs) |
| **accentSage** | `#8FA998` | Muted Sage (Secondary Accents, Success) |
| **safetyCritical** | `#90353D` | Safety Red (Warnings, Critical Alerts) |
| **ink** | `#1A3A3A` | Dark Forest (Headings, Icons) |
| **textBody** | `#2C2C2C` | Charcoal (Body Text) |

## 2. Glassmorphism Specifications
Glass effects are used to create depth and a "Sanctuary" feel.

### Premium: SanctuaryGlassCard
*Used for: Hero inputs, Profile cards, Main dashboards*
- **Blur**: 18px
- **Fill**: White @ 14–16% opacity
- **Border**: White @ 25% opacity, 1.2px width
- **Shadow**: Black @ 12% opacity, Blur 25, Spread -2

### Standard: StandardGlass (or SurfaceGlass)
*Used for: Overlays, Modals, Secondary elements*
- **Blur**: 14–15px
- **Fill**: White @ 10–12% opacity
- **Border**: White @ 20% opacity, 1.0px width
- **Shadow**: Black @ 6% opacity, Blur 20

## 3. Motion Rules
"Clinical Calm" - Motion never startles, it breathes.

- **Curve**: `Curves.easeInOut` (GentleEase)
- **Duration (Standard)**: 800ms
- **Ambient Loops**: 12–15s (Breathing, Floating)
- **Toggle**: Global "Motion Toggle" available in Preferences (default: ON).

## 4. Verification Logic (Region-Aware)
Labeling changes based on the user's geolocation or context to build maximum trust.

- **India / Asia**: "Board Verified"
- **US / Europe**: "Physician Verified"
- **Unknown / Default**: "Clinically Verified"

## 5. Rive Integration Checklist
The Rive pipeline is "Silence-First" (fails gracefully).

- **Asset Path**: `assets/rive/atmosphere.riv`
- **Config**: Add to `pubspec.yaml` under `assets:` if implementing.
- **Test**:
  - **With File**: App shows Rive background locally.
  - **Without File**: App logs "Asset missing... Using fallback" ONCE and shows Mesh Gradient.
  - **Debug Toggle**: Use "Motion" pill (top-right) to force Mesh fallback.

## 6. Phase 2: Cinematic Entry
Premium first impression with custom Flutter animations (no Rive required).

### CinematicSplashScreen
- **Duration**: 2.2s before transition
- **God Rays**: 15s loop, 5 rotating beams (#D4A373 @ 6% opacity)
- **Logo Float**: 3s gentle bob (±12px vertical sine wave)
- **Film Grain**: 150ms flicker, ~200 dots @ 2% opacity
- **Transition**: 800ms fade with `Curves.easeInOut`

### AuthEntryScreen
- **Glass Bottom Sheet**: Sigma 18 blur, 12% white fill, 25% border
- **Staggered Text**: Line-by-line fade + 20px slide (300ms intervals)
- **Buttons**: SanctuaryButton with scale (0.98), shimmer, haptic

### Motion OFF Behavior
- God rays, logo float, film grain: **disabled**
- Static logo and text remain
- Buttons still respond to press (scale/shimmer)

## 7. Phase 3: Intake UI Rules
Premium clinic intake with custom controls (no default Material widgets).

### SanctuaryToggleChip
- **States**: Selected (18% white fill, Ember Gold border 60% @ 1.5px) / Unselected (8% white, 25% border @ 1.0px)
- **Tap Animation**: Scale to 0.98, duration 160ms, `Curves.easeInOut`
- **Selected Glow**: Ember Gold shadow @ 15% opacity, blur 12
- **Icon + Label**: 18px icon, 15px text (600 weight when selected)

### SanctuaryTextField  
- **Fill**: 12% white
- **Border**: 25% white (default), 50% Ember Gold (focused) @ 1.0–1.5px
- **Focus Glow**: Ember Gold shadow @ 10% opacity, blur 12
- **Padding**: 16px horizontal, 4px vertical (inner content 12px vertical)

### SafetyBanner Types
| Type | Background | Border | Icon |
|---|---|---|---|
| **Info** | Sage 10% | Sage 30% | Sage 100% |
| **Amber** | Ember Gold 10% | Ember Gold 35% | Ember Gold 100% |
| **Critical** | Safety Red 12% | Safety Red 40% | Safety Red 100% |

### Form Spacing
- Section gap: 20px
- Field gap within section: 16px
- Button top margin: 32px

### Stagger Animation
- **Enabled** (Motion ON): 300ms intervals, fade + 20px slide
- **Disabled** (Motion OFF): Instant render (controller.value = 1.0)
- Micro-interactions (tap scale) always enabled

## 8. Phase 4: Home Dashboard Rules
Premium "museum dashboard" with Flutter-only animations (NO Rive required).

### Header (Region-Aware)
- **Greeting**: Time-based ("Good Morning" / "Good Afternoon" / "Good Evening")
- **Subtext**: "Your Sanctuary is ready."
- **Verification Pill**: Glass container (12% white fill, 25% teal border)
  - Icon: `Icons.verified_rounded` (14px, Deep Teal)
  - Label: 10px, 600 weight, 0.5 letter spacing
  - Primary source: User profile `region` field
  - Fallback 1: Device locale `countryCode`
  - Fallback 2: Timezone offset (last resort)

### Wellness Pulse Ring
- **Component**: `LiquidHealStreakRing` (existing)
- **Base**: Deep Teal stroke (#1F4E5F), 10px width
- **Wave Motion**: 3s loop (continuous when Motion ON)
- **Progress Animation**: ElasticOut, 800ms
- **Motion OFF**: Wave stops, static fill remains
- **Label**: "TODAY'S RHYTHM" (10px, 800 weight, 2.0 letter spacing)

### Wellness Pulse Hero (Glass Card)
- **Container**: `SanctuaryGlassCard` under ring
- **Metric**: "Total Health Impact" (20px value, 700 weight, Deep Teal)
- **Next Action**: Teal glass container (5% teal fill, 8px radius)
  - Icon: `Icons.water_drop_outlined` (16px)
  - Text: "Hydration window opens in 22m" (12px, 500 weight)

### Quick Action Chips
- **Base**: Glass container (12% white fill, 25% border, 12px radius)
- **Press**: Scale 0.98, 160ms, `Curves.easeInOut`
- **Glow**: Teal shadow @ 5% opacity, blur 8, offset (0, 2)
- **Layout**: Wrap spacing 12px, centered
- **Icon + Label**: 20px icon, 14px text (600 weight, 0.3 letter spacing)

### Premium Search Bar (SanctuarySearchBar)
- **Base**: Glass container (12% white fill, 25% border)
- **Focus State**:
  - Border: 50% Ember Gold (#D4A373), 1.5px width
  - Glow: Teal shadow @ 15% opacity, blur 12, offset (0, 4)
  - Transition: 220ms, `Curves.easeInOut`
- **Haptic**: `HapticFeedback.lightImpact()` on submit (safe fallback)

### Motion OFF Behavior
- Wave animation in ring: **disabled**
- Shimmer effects: **disabled**
- Press animations (scale, tap): **always enabled** (micro-interactions)
- Timeline expand: instant (no animation)
- Search focus glow: **always enabled**
