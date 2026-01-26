🌿 RemediBook: Master Blueprint & Vision
1. Vision & Core Philosophy
Vision: To bridge the gap between ancient ancestral wisdom and modern quick-commerce convenience. Philosophy: "Food as Medicine." We empower users to find safe, verified, natural remedies for minor ailments using ingredients already in their kitchen or available for 10-minute delivery. The Moat: A "Triad of Trust" (Remedy, Practice, Practitioner) grounded in a human-verified medical database, preventing AI hallucination.

2. Tech Stack
Frontend: Flutter (Mobile - iOS/Android)

AI Orchestration: Google Antigravity (Agentic Workflows)

AI Models: Gemini 3 Pro (Reasoning & Text), Gemini 3 Vision (Herb Identification)

Backend/DB: Firebase (Auth, Firestore for the Expert-Vault, Storage for PDFs)

Commerce Integration: Mocked API/Scraper for Zepto & Blinkit price/speed comparison.

3. The Agentic Architecture
Antigravity operates as the "Chief Wellness Officer." It follows this loop:

Listen: Accept Voice/Text/Photo input from the Flutter app.

Triage: Check against Red_Flags. If found, trigger immediate medical escalation.

Reason: Query the Golden_Ailments_DB. Match symptoms to verified remedies.

Fulfill: Check local Quick-Commerce availability for ingredients.

Generate: Create a personalized "Safe-Heal Guide" (PDF).

4. Feature Roadmap (Iterative Build)
Milestone 1: The Safety Foundation (Current Focus)
[ ] Create expert_vault.csv (The Golden 10 Ailments).

[ ] Implement the Triage Agent in Antigravity.

[ ] Logic: If input matches a Red_Flag, return a "Danger" state. If safe, return a "Grounded Remedy."

Milestone 2: The Flutter Interface
[ ] "Ancestral" Theme: Earthy tones, calm UI.

[ ] Symptom Input Bar + Multimodal FAB (Floating Action Button).

[ ] Result Cards: The Triad View (Remedy, Practice, Practitioner).

Milestone 3: The "Money" Feature (Quick-Commerce)
[ ] Ingredient extraction from Remedy.

[ ] Price/Speed Comparison Tool: Zepto vs. Blinkit.

[ ] One-tap "Add to Cart" logic.

Milestone 4: Multimodal & Vision
[ ] "Snap & Identify": Use Gemini Vision to identify kitchen herbs.

[ ] Verify if the herb in the user's hand matches the prescribed remedy.

Milestone 5: Personalization & PDF
[ ] Generate downloadable "Parchment Style" PDF prescriptions.

[ ] User "Savings Dashboard": Calculate money saved vs. clinical visits.

5. Coding & Safety Guardrails
Grounding Rule: Never suggest a remedy NOT found in the expert_vault.

Disclaimer Rule: Every output must include a regional legal disclaimer.

Code Style: Clean Flutter (BLoC or Provider for State), Modular Python for Antigravity tools.