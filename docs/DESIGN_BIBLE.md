# RemediBook Sanctuary — Design Bible
**Version 1.0** | Single Source of Truth for UI, Motion, Color, Typography & Components

---

## A) Brand Mood & Principles

### Core Philosophy
**"Clinical Magic" + "Quiet Luxury" + "Ancient wisdom, modern safety"**

RemediBook Sanctuary is a premium wellness platform that bridges Ayurvedic heritage with evidence-based safety. Every interaction should feel:
- **Ceremonial, not casual** — Deliberate pacing, breath-like motion
- **Trustworthy, not trendy** — Clinical precision meets warm humanity
- **Grounded, not flashy** — Quiet luxury through restraint and craft

### Motion Philosophy
> **"Motion as Breath"**

All animations follow organic, breath-like rhythms:
- **Never bouncy** — No spring physics, no aggressive easing
- **Slow and ceremonial** — Default 0.8s duration
- **Gentle ease** — Smooth in, smooth out (cubic-bezier)
- **Staggered reveals** — Line-by-line, card-by-card (120ms stagger)

### Design Principles
1. **Biophilic Calm** — Living backgrounds, organic motion, natural textures
2. **Glassmorphism with Purpose** — Depth through layering, not decoration
3. **Typography as Voice** — Serif for wisdom, sans for clarity
4. **Haptics as Ritual** — Tactile feedback for meaningful moments only
5. **Performance First** — Smooth on mid-range Android (60fps minimum)

---

## B) Color Tokens

### Primary Palette

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| **Limestone** | `#F2F0E6` | `242, 240, 230` | Primary background, canvas |
| **Deep Limestone** | `#E8E5D5` | `232, 229, 213` | Secondary background, breathing gradient |
| **Deep Teal** | `#1F4E5F` | `31, 78, 95` | Primary brand, trust, clinical |
| **Ember Gold** | `#D4A373` | `212, 163, 115` | Primary action, highlight, warmth |
| **Soft Amber** | `#E8D4B8` | `232, 212, 184` | Secondary accent, gentle emphasis |
| **Muted Sage** | `#8FA998` | `143, 169, 152` | Tertiary, missed states, calm |
| **Charcoal** | `#2C2C2C` | `44, 44, 44` | Body text, high contrast |
| **Clinical Red** | `#C84B31` | `200, 75, 49` | Warnings, escalation, danger |

### Usage Rules

**Backgrounds**:
- Primary: Limestone (#F2F0E6)
- Breathing gradient: Limestone → Deep Limestone
- Glass card fill: White at 12% opacity

**Actions**:
- Primary CTA: Ember Gold (#D4A373)
- Secondary CTA: Deep Teal outline
- Destructive: Clinical Red

**Text**:
- Headings: Charcoal (#2C2C2C)
- Body: Charcoal at 80% opacity
- Disabled: Charcoal at 40% opacity

**States**:
- Active/Current: Ember Gold
- Completed: Deep Teal
- Missed: Muted Sage
- Future/Locked: Charcoal at 30% opacity

---

## C) Typography Tokens

### Font Families

**Serif (Headlines & Wisdom)**:
- Primary: `Crimson Pro` or `Lora`
- Usage: Hero headlines, section titles, ceremonial text
- Fallback: Georgia, serif

**Sans-Serif (Body & UI)**:
- Primary: `Inter`
- Usage: Body text, buttons, labels, data
- Fallback: -apple-system, system-ui, sans-serif

### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| **Display** | 48px | 600 | 1.1 | -0.02em | Hero headlines |
| **H1** | 36px | 600 | 1.2 | -0.01em | Page titles |
| **H2** | 28px | 600 | 1.3 | 0em | Section headers |
| **H3** | 22px | 600 | 1.4 | 0em | Subsection headers |
| **H4** | 18px | 600 | 1.4 | 0.01em | Card titles |
| **Body Large** | 16px | 400 | 1.6 | 0em | Primary body |
| **Body** | 14px | 400 | 1.6 | 0em | Secondary body |
| **Body Small** | 13px | 400 | 1.5 | 0.01em | Captions, metadata |
| **Label** | 12px | 600 | 1.4 | 0.05em | Buttons, chips, labels |
| **Micro** | 11px | 500 | 1.3 | 0.05em | Timestamps, footnotes |

### Typography Rules

1. **Headings**: Use serif (Crimson Pro) for warmth and authority
2. **Body**: Use sans (Inter) for clarity and readability
3. **All-caps**: Only for micro labels (e.g., "DAY STREAK")
4. **Letter spacing**: Tighter for large text, wider for small labels
5. **Color**: Charcoal for text, never pure black
6. **Opacity**: 100% for headings, 80% for body, 40% for disabled

---

## D) Surfaces

### SanctuaryGlassCard

**Specification**:
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
        width: 1.2,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 25,
          spreadRadius: -2,
          offset: Offset(0, 8),
        ),
      ],
    ),
  ),
)
```

**Visual Features**:
- Blur sigma: 18 (soft, premium)
- Fill: White 12% opacity
- Border: White 25% opacity, 1.2px
- Corner radius: 24px (premium roundness)
- Shadow: Black 12%, blur 25, spread -2, offset (0, 8)
- Inner highlight: Top edge gradient stroke (white 15% → transparent)

**Usage Rules**:
- Only use on textured backgrounds (never solid color)
- Limit to hero cards (not full-screen lists)
- Provide `reduceMotion` variant (solid surface, no blur)

---

### PaperSurface

**Specification**:
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFFFFDF8), // Warm white
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

**Usage**: Remedy cards, ingredient lists, static content

---

### InkSurface

**Specification**:
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF1F4E5F), // Deep Teal
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF1F4E5F).withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 6),
      ),
    ],
  ),
)
```

**Usage**: Primary action buttons, active states, emphasis

---

## E) Motion System (Global)

### Default Transition

**Curve**: Gentle Ease (Cubic Bezier)
```dart
static const Curve gentleEase = Curves.easeInOutCubic;
```

**Duration**: 800ms (0.8s)
```dart
static const Duration defaultDuration = Duration(milliseconds: 800);
```

### Stagger Rules

**Line-by-Line Text Reveal**:
- Stagger delay: 120ms per line
- Fade + Slide up (20px → 0px)
- Curve: Gentle Ease
- Total max: 5 lines (600ms total stagger)

**Card-by-Card List Reveal**:
- Stagger delay: 80ms per card
- Fade + Scale (0.95 → 1.0)
- Curve: Gentle Ease
- Max visible cards: 8 (640ms total stagger)

### Loading States

**Skeleton Shimmer**:
- Soft, slow shimmer (2s loop)
- Gradient: Limestone → Deep Limestone → Limestone
- Opacity: 0.3 → 0.6 → 0.3
- No harsh flashing

**Progress Indicators**:
- Circular: Deep Teal, 3px stroke
- Linear: Ember Gold fill, Limestone background
- No Material spinners

### Screen Transitions

**Page Routes**:
```dart
PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 800),
  pageBuilder: (context, animation, secondaryAnimation) => nextPage,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
      child: child,
    );
  },
)
```

**Modal Overlays**:
- Fade in: 600ms
- Backdrop blur: Animate sigma 0 → 12
- Content: Fade + Scale (0.95 → 1.0)

---

## F) Haptics & Sound

### Haptic Feedback

**When to Vibrate**:
- ✅ Timer completion (medium impact)
- ✅ Wax seal stamp (heavy impact)
- ✅ Confirmation actions (light impact)
- ✅ Step completion (medium impact)
- ❌ Navigation (no haptic)
- ❌ Scrolling (no haptic)
- ❌ Typing (no haptic)

**Implementation**:
```dart
import 'package:flutter/services.dart';

// Light: UI confirmations
HapticFeedback.lightImpact();

// Medium: Step completion, timer finish
HapticFeedback.mediumImpact();

// Heavy: Seal stamp, major milestone
HapticFeedback.heavyImpact();
```

**User Control**:
- Settings toggle: "Haptic Feedback" (default: ON)
- Respect system accessibility settings
- Graceful degradation on web

### Sound (Optional)

**Audio Cues** (if implemented):
- Seal stamp: Soft "thud" (200ms, warm tone)
- Timer finish: Gentle chime (300ms, bell-like)
- Volume: 40% max
- User toggle: "Sound Effects" (default: OFF)

---

## G) Component Library Index

### Core Widgets

| Component | File Path | Usage |
|-----------|-----------|-------|
| **BreathingBackground** | `lib/core/widgets/living_background.dart` | Entry, Onboarding, Home, Search |
| **SanctuaryGlassCard** | `lib/core/widgets/sanctuary_glass_card.dart` | Hero cards, modals |
| **StaggeredFadeSlideText** | `lib/core/widgets/staggered_text.dart` | Heritage onboarding, ceremonial text |
| **LiquidHealStreakRing** | `lib/features/dashboard/presentation/widgets/heal_streak_ring.dart` | Dashboard streak display |
| **CircularStepTimer** | `lib/features/remedy/widgets/circular_step_timer.dart` | Preparation steps |
| **InventoryChips** | `lib/features/remedy/widgets/inventory_chips.dart` | Ingredient availability |
| **WaxSealStampAnimation** | `lib/features/artifact/widgets/wax_seal_stamp.dart` | PDF generation confirmation |
| **SanctuaryButton** | `lib/core/widgets/sanctuary_button.dart` | Primary actions (Ember Gold) |
| **GrainOverlay** | `lib/core/widgets/grain_overlay.dart` | Texture layer for richness |
| **TriadOfTrust** | `lib/features/remedies/widgets/triad_of_trust.dart` | 3-layer expandable glass accordion |
| **DynamicRefiners** | `lib/features/remedies/widgets/dynamic_refiners.dart` | Personalization chips |
| **SafetyEscalationBanner** | `lib/features/remedies/widgets/safety_escalation_banner.dart` | Caution/Urgent alerts |
| **PrepSteps** | `lib/features/remedies/widgets/prep_steps.dart` | Preparation timeline |

### Layout Components

| Component | File Path | Usage |
|-----------|-----------|-------|
| **SanctuaryScaffold** | `lib/core/widgets/sanctuary_scaffold.dart` | Base layout with breathing background |
| **GlassAppBar** | `lib/core/widgets/glass_app_bar.dart` | Transparent app bar with blur |
| **FloatingGlassNav** | `lib/core/widgets/floating_glass_nav.dart` | Bottom navigation (if needed) |

### Specialty Widgets

| Component | File Path | Usage |
|-----------|-----------|-------|
| **VernacularBridge** | `lib/core/widgets/vernacular_bridge.dart` | Local language ingredient names |
| **DeepLinkBuilder** | `lib/core/services/deep_link_builder.dart` | Grocery cart deep links |
| **SkeletonShimmer** | `lib/core/widgets/skeleton_shimmer.dart` | Loading states |

---

## H) Implementation Status

### Phase 0: Design Lock ✅
- [x] Design Bible created
- [x] All tokens documented
- [x] Component specs defined

### Phase 1: Living Background ✅
- [x] BreathingBackground implemented
- [x] Grain overlay added
- [x] Applied to 4 hero screens (Splash, Onboarding, Dashboard, Search/Inquiry)
- [x] Performance validated (CustomPainter with cached repaints)

### Phase 2: Glassmorphism ✅
- [x] SanctuaryGlassCard created
- [x] Replaced existing cards in Onboarding and Discovery screens
- [x] PaperSurface and InkSurface variants created
- [x] Validated glass effect on textured background

### Phase 3: Liquid Heal Streak ✅
- [x] Liquid fill animation with wave motion
- [x] Splash and settle on progress change (ElasticOut 800ms)
- [x] Continuous wave loop (3s cycle)
- [x] Reduce motion support
- [x] Performance validated (CustomPainter with shouldRepaint)

### Phase 4: Sovereign Triad 2.0 ✅
- [x] CircularStepTimer with tap-to-start, pause/resume, haptic feedback
- [x] InventoryChips with three states and gentle ease transitions
- [x] DeepLinkBuilder supporting Amazon, BigBasket, Blinkit
- [x] Shopping list text generation for sharing

### Phase 5a: Gemini 3 Integration ✅
- [x] VernacularBridge with offline dictionary (15+ ingredients, 5 languages)
- [x] Geo-context awareness (Hyderabad/Telugu focus)
- [x] StaggeredFadeSlideText with 120ms stagger, fade + slide animations
- [x] Reduce motion support for all animations

### Phase 5b: Signature Experience UI (Remedy & Discovery) ✅
- [x] **Discovery Screen**: "Triage Agent" search bar, suggested prompts, region-aware result cards.
- [x] **Triad of Trust**: 3-layer glass accordion (Traditional, Science, Safety) with "unfolding" motion.
- [x] **Dynamic Refiners**: Personalization chips simulating AI content transformation.
- [x] **Safety Escalation**: Adaptive banners (Caution/Urgent) with Garnet/Amber styling.
- [x] **Preparation Path**: Integrated `CircularStepTimer` and `PrepSteps` widget.
- [x] **Inventory**: "Have/Need" toggle logic with smart cart summary.

---

## I) Performance Guidelines

### Optimization Rules

1. **BackdropFilter**: Limit to hero surfaces only (not full-screen)
2. **CustomPainter**: Use `shouldRepaint` wisely, cache when possible
3. **Animations**: Dispose controllers properly, use `SingleTickerProviderStateMixin`
4. **Images**: Compress assets, use `cacheWidth`/`cacheHeight`
5. **Lists**: Use `ListView.builder`, not `ListView` with all children
6. **Blur**: Avoid expensive blur on scrolling lists

### Target Performance

- **Frame rate**: 60fps minimum on mid-range Android
- **Jank threshold**: <16ms per frame
- **Cold start**: <3s to first interactive frame
- **Memory**: <200MB peak usage

### Reduce Motion Support

All animations must provide a `reduceMotion` variant:
- Disable breathing background motion
- Replace glass blur with solid surface
- Instant transitions (no fade/slide)
- Respect `MediaQuery.of(context).disableAnimations`

---

## J) Accessibility

### Contrast Ratios

- **Body text**: 4.5:1 minimum (WCAG AA)
- **Large text**: 3:1 minimum
- **Interactive elements**: 3:1 minimum

### Touch Targets

- **Minimum**: 48x48 logical pixels
- **Preferred**: 56x56 for primary actions

### Screen Reader Support

- All interactive elements have semantic labels
- Decorative elements marked as `excludeSemantics: true`
- Meaningful focus order

---


## Phase 8: Artifact Experience
The "Artifact" is a ceremonial output of the user's journey.

**1. PDF Guidelines**
*   **Typography**: Serif headlines (Times/Crimson), Sans body (Helvetica/Inter).
*   **Branding**: Minimal watermarks. No heavy logos. "RemediBook Sanctuary" header.
*   **Verification**: Always display the "Board Verified" or "Clinically Verified" pill near the title.

**2. The Wax Seal (`DigitalWaxSeal`)**
*   **Visual**: Radial gradient (Crimson 900 -> Red 700). 3D BoxShadows.
*   **Animation**:
    *   *Scale*: 0.6 -> 1.0 (ElasticOut, 700ms).
    *   *Rotation*: -6° -> 0° (EaseOutBack, 800ms).
*   **Haptics**: `MediumImpact` on the visual "stamp" hit.
*   **MotionPrefs**: If disabled, render instantly at scale 1.0.

**3. Ceremony Timing**
*   "Preparing parchment..." (600ms+)
*   "Inscribing wisdom..." (600ms+)
*   Reveal PDF -> Wait 300ms -> Stamp Seal.

---

**End of Design Bible v1.0**

*This document is the single source of truth. All code must reference this spec in comments.*
