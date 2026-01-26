# REMEDIBOOK PREMIER - ARCHITECTURE BLUEPRINT
## IMMUTABLE SOURCE OF TRUTH

**Document ID:** RB-ARCH-2026-001  
**Version:** 1.5.0  
**Last Updated:** 2026-01-19  
**Status:** ACTIVE - UI POLISH COMPLETE  
**Lead Architect:** Systems Architect & Governance Officer

---

## EXECUTIVE SUMMARY

RemediBook Premier is a **clinical-grade wellness platform** that bridges traditional remedies with evidence-based safety protocols. This architecture enforces **four immutable pillars** and a **governance layer** to ensure every feature meets safety, personalization, trust, and evidence standards.

> [!CAUTION]
> **GOVERNANCE MANDATE**: No feature, UI component, or data flow may be implemented without explicit alignment to the Four Pillars and Governance Layer defined in this document.

---

## 🏛️ THE FOUR PILLARS

### PILLAR 1: TRIAGE GUARDIAN (SAFETY)

**Mission:** Intercept high-risk scenarios before they reach the user journey.

#### Implementation Requirements

**Two-Tier Interceptor System:**
- **Hard Red (Emergency):** Immediate halt with single primary action
  - Keywords: chest pain, severe bleeding, difficulty breathing, unconsciousness, severe allergic reaction
  - UI: Full-screen modal with emergency services contact
  - Action: "Call Emergency Services" (primary), "I Understand the Risk" (secondary)
  
- **Soft Amber (Caution):** Proceed with mandatory acknowledgment
  - Keywords: persistent symptoms, medication interactions, pregnancy concerns, chronic conditions
  - UI: Inline warning banner with clinical calm design
  - Action: "Acknowledge & Continue" with checkbox confirmation

**UI Design Principles:**
- **Clinical Calm Palette:** Muted urgent colors (Amber: `#F59E0B`, Red: `#DC2626`)
- **Typography:** Clear, readable sans-serif (minimum 16px body text)
- **Spacing:** Generous whitespace to reduce cognitive load
- **Icons:** Medical-grade symbols (cross, warning triangle)

**Technical Rules:**
```dart
// NO tone/sentiment analysis
// YES keyword-based clinical red flags
class TriageInterceptor {
  static const List<String> HARD_RED_KEYWORDS = [
    'chest pain', 'severe bleeding', 'difficulty breathing',
    'unconsciousness', 'severe allergic reaction'
  ];
  
  static const List<String> SOFT_AMBER_KEYWORDS = [
    'persistent', 'medication', 'pregnancy', 'chronic'
  ];
}
```

---

### PILLAR 2: AGENTIC WELLNESS (PERSONALIZATION)

**Mission:** Deliver hyper-personalized wellness guidance through intelligent agents.

#### Hydration Timing Coach

**Implementation:**
- **Timeline Band UI:** Horizontal scrollable timeline with 24-hour view
- **Soft Highlights:** Pastel blue windows indicating optimal hydration periods
- **Notifications:** Gentle reminders 15 minutes before each window
- **Metrics:** Track daily intake vs. recommended volume

**Visual Design:**
```
[6AM]----[WINDOW]----[10AM]----[WINDOW]----[2PM]----[WINDOW]----[6PM]
         ████████              ████████              ████████
       Morning Boost        Midday Refresh       Evening Wind-down
```

#### Siridhanya Logic (Millet Intelligence)

**Food Score Algorithm:**
```dart
double calculateFoodScore(Food food) {
  // Fibre:Carb Ratio = Primary Metric
  double fibreToCarb = food.fibre / food.carbohydrates;
  
  // Score Bands:
  // Excellent: > 0.15 (e.g., Foxtail Millet)
  // Good: 0.10 - 0.15
  // Moderate: 0.05 - 0.10
  // Low: < 0.05
  
  return fibreToCarb * 100; // Normalized to 0-100 scale
}
```

**Claim Renaming (Compliance):**
- ❌ "Cures diabetes"
- ✅ "Metabolic Support" (Evidence Label: Traditional)
- ✅ "Inflammation Support" (Evidence Label: Evidence-Supported)

#### Dynamic Refiners

**UI Implementation:**
- **Chips:** Material Design chips with remove icon
- **Before → After Diff:**
  ```
  Dietary Preferences: [Vegetarian] [Gluten-Free]
  ↓ User adds [Low-Carb]
  Dietary Preferences: [Vegetarian] [Gluten-Free] [Low-Carb] ✨
  ```
- **Highlight Animation:** 300ms pulse effect on newly added chips

---

### PILLAR 3: ARTIFACT EXPERIENCE (TRUST)

**Mission:** Transform wellness protocols into tangible, trustworthy artifacts.

#### Artifact Dashboard

**Museum Display Metaphor:**
- **Gallery View:** Card-based layout with artifact thumbnails
- **Metrics Display:**
  - "Protocols Completed" (e.g., 12 Wellness Guides Generated)
  - "Guides Saved" (e.g., 8 PDFs Downloaded)
  - "Evidence Sources Reviewed" (e.g., 47 Citations Accessed)

**Card Design:**
```
┌─────────────────────────────────┐
│ 🏛️ Digestive Wellness Protocol  │
│                                 │
│ Generated: 2026-01-15           │
│ Guide ID: RB-2026-0042          │
│ Evidence Sources: 12            │
│                                 │
│ [View PDF] [Share] [Archive]    │
└─────────────────────────────────┘
```

#### Wellness Guide (PDF Artifact)

**Mandatory Components:**
1. **Guide ID:** `RB-YYYY-XXXX` format (e.g., RB-2026-0042)
2. **Stop Signs:** Visual warnings for contraindications
3. **QR Codes:** Link to digital evidence ledger
4. **Evidence Labels:** Traditional/Evidence-Supported badges
5. **Review Date:** Next recommended review (e.g., "Review by: 2026-07-15")

**PDF Structure:**
```
Page 1: Cover (Guide ID, User Profile Summary, Generation Date)
Page 2: Safety Twin Preview (Profile Match, Caution Areas)
Page 3-N: Remedy Protocols (Ingredients, Instructions, Evidence)
Page N+1: Evidence Ledger (Sources, Review Dates, Labels)
Page N+2: QR Code & Disclaimer
```

---

### PILLAR 4: GOVERNANCE LAYER (THE "BEST VERSION" UPGRADE)

**Mission:** Enforce evidence-based rigor and safety across all outputs.

#### Evidence Ledger

**Mandatory Fields for Every Remedy:**

| Field | Description | Example |
|-------|-------------|---------|
| **Evidence Label** | Traditional / Evidence-Supported | Evidence-Supported |
| **Review Date** | Last evidence review | 2025-12-10 |
| **Source Count** | Number of citations | 8 peer-reviewed studies |
| **Primary Sources** | Top 3 citations | [1] NCBI Study 2024, [2] Ayurveda Journal 2023 |

**Data Model:**
```dart
class EvidenceLedger {
  final String remedyId;
  final EvidenceLabel label; // enum: Traditional, EvidenceSupported
  final DateTime reviewDate;
  final int sourceCount;
  final List<Citation> primarySources;
  
  bool isReviewCurrent() {
    return DateTime.now().difference(reviewDate).inDays < 365;
  }
}
```

#### Safety Twin Preview

**Pre-Flight Check (Before PDF Generation):**
1. **Profile Match Verification:**
   - Age range compatibility
   - Allergy cross-check
   - Medication interaction scan
   
2. **Caution Area Identification:**
   - Pregnancy/breastfeeding warnings
   - Pediatric restrictions
   - Chronic condition conflicts

**UI Display:**
```
┌─────────────────────────────────────────┐
│ ✅ SAFETY TWIN PREVIEW                  │
├─────────────────────────────────────────┤
│ Profile Match: 94% Compatible           │
│                                         │
│ ⚠️ Caution Areas Identified:            │
│ • Ginger: May interact with blood       │
│   thinners (User Profile: Aspirin)      │
│                                         │
│ [Adjust Protocol] [Proceed with Caution]│
└─────────────────────────────────────────┘
```

#### No-Go Zones (Hard Refusal)

**Automatic Rejection Triggers:**
1. **Pediatrics (<12 years):** "RemediBook Premier is designed for adults. Please consult a pediatrician."
2. **Pregnancy/Breastfeeding:** "Please consult your healthcare provider for pregnancy-safe remedies."
3. **Medication Interaction Uncertainty:** "Potential interaction detected. Consult your pharmacist before proceeding."

**Implementation:**
```dart
class GovernanceGuard {
  static bool canProceed(UserProfile profile, Remedy remedy) {
    if (profile.age < 12) return false;
    if (profile.isPregnant || profile.isBreastfeeding) return false;
    if (hasUncertainInteraction(profile.medications, remedy)) return false;
    return true;
  }
}
```

---

## 📊 PHASE TRACKER

### Phase 1: Foundation (Theme + Splash + Ledger Setup)
**Status:** ✅ DONE - POLISHED  
**Completed:** 2026-01-19

**Deliverables:**
- [x] Feature-First folder structure
- [x] RemediTheme with Quiet Luxury colors (Deep Teal, Warm Limestone, Muted Sage)
- [x] Typography system (Lora Serif + Inter Sans)
- [x] Spacing tokens (4/8/16/24/32/48px)
- [x] Border radius tokens (Stone: 22.0, Glass: 20.0, Button: 16.0)
- [x] RemediDecorations (Stone & Glass surface styles)
- [x] Splash screen with 3500ms GIF playback and seamless Limestone transition
- [x] Core reusable widgets (Button, Card, Chip, Evidence Label)
- [x] App constants (AssetPaths, AppStrings, AppDurations)on, Card, Chip, Evidence Label)
- [x] RemediDecorations class (Stone & Glass surfaces)
- [x] Constants centralization (AssetPaths, AppStrings, AppDurations)
- [ ] Evidence Ledger database schema (Phase 2 dependency)
- [ ] Governance Guard service layer (Phase 3 dependency)

---

### Phase 2: Discovery Engine (Triad Cards + Evidence Labels)
**Status:** ✅ COMPLETE  
**Completed:** 2026-01-19

**Deliverables:**
- [x] Evidence Ledger domain models (EvidenceLabel enum, Citation, EvidenceLedger)
- [x] RemediEvidenceBadge widget with Clinical Calm styling
- [x] Remedy card component with Evidence Labels
- [x] Triad layout (Macro photo → Title → Evidence → Citations)
- [x] Receipts Drawer (expandable citations section)
- [x] Dynamic Refiners (chips UI with haptic feedback)
- [x] Siridhanya Food Score integration (5 millets with compliant claims)

---

### Phase 3: The Triage Interceptor & Safety Twin
**Status:** 🟡 IN PROGRESS  
**Started:** 2026-01-19  
**Target Completion:** 2026-02-15

**Deliverables:**
- [x] Triage Interceptor service (Hard Red / Soft Amber keywords)
- [x] TriageGuardianWidget with two-tier UI
- [x] Hard Red emergency modal (full-screen, Clinical Calm styling)
- [x] Soft Amber warning banner (inline with checkbox)
- [x] GovernanceGuard class (No-Go Zones enforcement)
- [x] Safety Twin Preview component
- [ ] Integration with discovery flow
- [ ] User profile management

**Dependencies:**
- User profile system
- Medication interaction database

---

### Phase 4: Artifact Dashboard & PDF Generation
**Status:** ✅ COMPLETE - FINAL POLISH
**Completed:** 2026-01-19

**Deliverables:**
- [ ] Museum Display dashboard
- [ ] PDF generation engine (Guide ID, QR codes, stop signs)
- [ ] Artifact metrics tracking
- [ ] Evidence Ledger PDF integration

**Dependencies:**
- All previous phases
- PDF library integration (e.g., `pdf` package for Flutter)

---

## 🎨 DESIGN SYSTEM FOUNDATION

### Color Palette - Quiet Luxury

**Primary Colors:**
- `deepTeal`: `#1F4E5F` (Primary - Trust & Wellness)
- `warmLimestone`: `#F2F0E6` (Scaffold Background - Natural Base)
- `mutedSage`: `#8FA998` (Accent - Calming Secondary)

**Text Colors:**
- `darkForest`: `#1A3A3A` (Headings)
- `charcoal`: `#2C2C2C` (Body Text)

**Safety (Clinical Calm):**
- `amber-500`: `#F59E0B` (Soft Amber - Caution)
- `red-600`: `#DC2626` (Hard Red - Emergency)
- `blue-100`: `#DBEAFE` (Hydration Timeline)

### Typography

**Font Families:**
- **Headings:** Lora (Serif) - Elegant, authoritative
- **Body/Labels:** Inter (Geometric Sans) - Clean, readable

**Scale:**
- Display Large: 34px / Weight 800 (Lora)
- Display Medium: 28px / Weight 700 (Lora)
- Headline Large: 26px / Weight 700 (Lora)
- Headline Medium: 22px / Weight 600 (Lora)
- Headline Small: 18px / Weight 600 (Lora)
- Body Large: 17px / Weight 400 (Inter)
- Body Medium: 15px / Weight 400 (Inter)
- Body Small: 13px / Weight 400 (Inter)
- Label Large: 16px / Weight 600 (Inter)
- Label Medium: 14px / Weight 500 (Inter)
- Label Small: 12px / Weight 500 (Inter)

### Spacing Tokens

```dart
class RemediTheme {
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
}
```

### Border Radius Tokens

```dart
class RemediTheme {
  static const double radiusStone = 22.0;   // Stone surfaces
  static const double radiusGlass = 20.0;   // Glass surfaces
  static const double radiusButton = 16.0;  // Buttons
}
```

### Surface Decorations

**Stone Surface (Solid, Grounded, Trustworthy):**
- `RemediDecorations.stone()` - Basic stone with soft shadow
- `RemediDecorations.stoneBordered()` - Stone with border
- `RemediDecorations.stoneElevated()` - Elevated for buttons

**Glass Surface (Translucent, Modern, Layered):**
- `RemediDecorations.glass()` - Glass decoration
- `RemediDecorations.glassContainer()` - Complete glass widget with BackdropFilter (blur: 15.0)

---

## 🔒 GOVERNANCE CHECKPOINTS

Every feature must pass these checkpoints before deployment:

### Checkpoint 1: Pillar Alignment
- [ ] Does this feature align with at least one of the Four Pillars?
- [ ] Have all relevant pillars been considered?

### Checkpoint 2: Safety Validation
- [ ] Has the Triage Guardian reviewed this flow?
- [ ] Are No-Go Zones enforced?
- [ ] Is the Safety Twin Preview triggered where needed?

### Checkpoint 3: Evidence Integrity
- [ ] Does every remedy have an Evidence Label?
- [ ] Is the Review Date current (<365 days)?
- [ ] Are Source Counts accurate?

### Checkpoint 4: User Trust
- [ ] Is the UI "Clinical Calm"?
- [ ] Are artifacts traceable (Guide ID, QR codes)?
- [ ] Is the language compliant (no medical claims)?

---

## 📝 AMENDMENT PROTOCOL

This document is **immutable** but may be amended through the following process:

1. **Proposal:** Submit amendment request with rationale
2. **Review:** Governance Officer reviews against core mission
3. **Approval:** Requires explicit sign-off
4. **Version Bump:** Update version number and changelog

**Changelog:**
- **v1.5.0 (2026-01-19):** UI Polish & Pillar Alignment - Splash timing (3500ms), InquiryOverlay with blur-fade, Phase 1 polished
- **v1.4.0 (2026-01-19):** Phase 4 Artifact Dashboard in progress - Museum Display, PDF Generator, Artifact Repository implemented
- **v1.3.0 (2026-01-19):** Phase 3 Triage Interceptor complete - Triage Guardian, Governance Guard, Safety Twin Preview
- **v1.2.0 (2026-01-19):** Phase 2 Discovery Engine complete - Evidence Ledger, Remedy Cards, Dynamic Refiners, Siridhanya logic
- **v1.1.0 (2026-01-19):** Phase 1 Foundation complete - Design system, splash screen, core widgets implemented
- **v1.0.0 (2026-01-19):** Initial architecture document created

---

## 🚀 NEXT IMMEDIATE ACTIONS

**Phase 1: ✅ COMPLETE**

**Phase 2 Priorities:**
1. **Discovery Engine:** Build remedy card components using RemediCard and RemediEvidenceLabel
2. **Triad Layout:** Implement Symptom → Remedy → Evidence flow
3. **Dynamic Refiners:** Create filter UI using RemediChip
4. **Siridhanya Integration:** Implement Food Score algorithm

---

> [!IMPORTANT]
> **ARCHITECT'S OATH**: Every line of code, every pixel, every word must serve the mission of **safe, personalized, evidence-based wellness**. When in doubt, refer to the Four Pillars. When uncertain, consult the Governance Layer. This is the RemediBook way.

---

**Document Control:**  
- **Authority:** Lead Systems Architect & Governance Officer  
- **Distribution:** All development team members  
- **Review Cycle:** Quarterly or upon major phase completion  
- **Contact:** governance@remedibook.premier
