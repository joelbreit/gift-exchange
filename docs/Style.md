# Style Guide
---
## 1. Typography
**Goal:** Friendly, clean, slightly playful.
**Font family:** font-sans (e.g. Inter / system UI)
**Headings:**
h1: text-4xl md:text-5xl font-semibold tracking-tight
h2: text-2xl md:text-3xl font-semibold
h3: text-xl font-semibold
**Body text:** text-base md:text-lg font-normal leading-relaxed
**Labels/UI text:** text-sm font-medium uppercase tracking-wide
**General rule:**
Use **at most 2 weights**: font-normal, font-semibold.
---
## 2. Spacing & Layout
**Goal:** Cozy, breathable, not cramped.
**Base spacing unit:** multiples of 4px (gap-2, gap-4, gap-6, etc.)
**Section padding:**
Page sections: py-12 md:py-16
Page sides: px-4 md:px-8
**Max content width:** max-w-5xl mx-auto
**Component padding:**
Cards: p-4 md:p-6
Buttons: px-4 py-2 (sm), px-5 py-2.5 (md)
---
## 3. Shape Language
**Goal:** Soft, rounded, snowball-y.
**Global radius:**
Cards & panels: rounded-xl
Inputs & buttons: rounded-full or rounded-lg (choose one and stick to it)
**Never use sharp corners (rounded-none) for primary UI.**
---
## 4. Icon Style
**Goal:** Simple, outlined, friendly.
**Icon type:** Outline icons only (e.g., Heroicons outline).
**Size:** w-5 h-5 by default, w-6 h-6 in hero areas.
**Placement:**
Icon + label buttons: icon on the **left**, gap-2.
**Do not mix** filled and outline styles in the same area.
---
## 5. Interaction & Motion
**Goal:** Light, snappy, “frosty but responsive.”
**Default transition:** transition-all duration-150 ease-out
**Buttons (hover):**
Slight lift: hover:-translate-y-0.5
Slight shadow increase: hover:shadow-md
**Clickable cards (hover):**
hover:-translate-y-1 hover:shadow-lg
**Focus styles:** Always visible focus ring:
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-300
**No long or bouncy animations** (keep it subtle and fast).
---
## 6. Shadow & Depth
**Goal:** Soft winter light, gentle depth.
**Base card shadow:** shadow-sm
**Hovered/elevated card:** shadow-lg
**Modals/popovers:** shadow-2xl
**Avoid multiple shadow styles** beyond these three.
---
## 7. Imagery & Illustration
**Goal:** Light, cozy winter without being holiday-specific.
**Photos:**
Soft lighting, cool temperature, lots of negative space.
**Illustrations:**
Flat or mildly 3D, rounded shapes, no harsh angles.
**Motifs:**
Snowflakes, soft hills, mugs, scarves, trees, clouds.
**Avoid:**
Strong holiday branding (no specific religious or dated holiday imagery).
---
## 8. Color (High-Level Note Only)
_Color palette is defined elsewhere. General vibe: cool, wintery blues with a single warm accent (e.g., a “mug of cocoa” color) for CTAs._
---