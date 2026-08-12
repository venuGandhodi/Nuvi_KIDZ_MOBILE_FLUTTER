---
name: Nuvi Playful Premium
colors:
  surface: '#fff8f0'
  surface-dim: '#e1d9cd'
  surface-bright: '#fff8f0'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fbf3e7'
  surface-container: '#f5ede1'
  surface-container-high: '#efe7db'
  surface-container-highest: '#e9e1d6'
  on-surface: '#1e1b14'
  on-surface-variant: '#424844'
  inverse-surface: '#343028'
  inverse-on-surface: '#f8f0e4'
  outline: '#727973'
  outline-variant: '#c2c8c2'
  surface-tint: '#466554'
  primary: '#082719'
  on-primary: '#ffffff'
  primary-container: '#1f3d2e'
  on-primary-container: '#87a894'
  inverse-primary: '#adceba'
  secondary: '#835400'
  on-secondary: '#ffffff'
  secondary-container: '#fdb244'
  on-secondary-container: '#6e4600'
  tertiary: '#460d00'
  on-tertiary: '#ffffff'
  tertiary-container: '#661f09'
  on-tertiary-container: '#eb8467'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c8ebd5'
  primary-fixed-dim: '#adceba'
  on-primary-fixed: '#022113'
  on-primary-fixed-variant: '#2f4d3d'
  secondary-fixed: '#ffddb5'
  secondary-fixed-dim: '#ffb956'
  on-secondary-fixed: '#2a1800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#ffdbd1'
  tertiary-fixed-dim: '#ffb5a0'
  on-tertiary-fixed: '#3b0900'
  on-tertiary-fixed-variant: '#7b2e17'
  background: '#fff8f0'
  on-background: '#1e1b14'
  surface-variant: '#e9e1d6'
typography:
  headline-xl:
    fontFamily: Quicksand
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

The design system is built for a premium kids' fashion brand that balances high-end quality with a warm, storybook-inspired playfulness. The aesthetic is "Premium-Casual"—sophisticated enough for parents who value quality, yet soft and imaginative enough to resonate with the world of childhood.

The visual direction leans into **Modern-Tactile Minimalism**. It avoids the harshness of high-tech interfaces in favor of soft, organic shapes and a grounded, earthy palette. Use whitespace generously to maintain a premium feel, while layering hand-drawn illustrative elements (stars, elephant motifs, orbit lines) to add a sense of wonder and movement. All interactions should feel gentle and fluid, mimicking the soft textures of children's apparel.

## Colors

The palette is rooted in a warm, organic foundation. 

- **Primary Background (#FBF3E7):** Use this warm cream for all major surface areas. It is softer on the eyes than pure white and reinforces the "premium cotton" feel.
- **Primary Anchor (#1F3D2E):** Use this deep forest green for navigation, primary headers, and grounding elements. It provides the "premium" weight to the system.
- **Primary CTA (#F2A93B):** Reserved for buttons and critical conversion points. This mustard yellow pops against the cream and green without being aggressive.
- **Secondary Accent (#E27D60):** Use for highlights, price tags, and illustrative accents to add warmth.
- **Text (#2D2D2D):** A deep charcoal used for body copy to ensure high legibility while appearing softer than pure black.

## Typography

This design system uses a combination of **Quicksand** for headings to evoke a friendly, storybook atmosphere and **Be Vietnam Pro** for body text to maintain a contemporary, clean, and highly legible feel.

- **Headings:** Always use rounded weights. Letter spacing should be slightly tightened for large displays to keep the "bubbly" feel cohesive.
- **Body:** Use a comfortable line height (1.5x) to ensure the text feels airy and approachable.
- **Micro-copy:** Labels for sizes or categories should be in semi-bold Be Vietnam Pro to distinguish them from descriptive text.

## Layout & Spacing

The layout follows a **fluid grid** model with generous margins to protect the premium aesthetic. 

- **Desktop:** 12-column grid with 24px gutters. Use wide 40px external margins to prevent content from feeling cramped.
- **Mobile:** 4-column grid with 16px gutters and margins.
- **Rhythm:** Use an 8px base unit for all padding and margins. Vertical rhythm should prioritize "breathing room"—double the standard spacing between unrelated sections (e.g., 80px or 120px) to allow the illustrations to "live" in the whitespace.

## Elevation & Depth

To maintain a soft, tactile feel, this design system avoids heavy shadows and floating layers.

- **Tonal Layering:** Depth is primarily created through subtle color shifts (e.g., placing a Forest Green card on the Cream background).
- **Soft Shadows:** When elevation is necessary (like on a hovering product card), use an "ambient glow" shadow: very high blur (20-30px), very low opacity (5-8%), and tinted with the Primary Anchor color (#1F3D2E) rather than black.
- **Flat Depth:** Use 1px solid borders in a slightly darker cream or muted sage for input fields and containers to maintain a clean, organized look without traditional "3D" depth.

## Shapes

The shape language is defined by **circularity and organic curves**. 

- **Component Radii:** Buttons and input fields use a standard 0.5rem (8px) radius. 
- **Large Containers:** Cards and image containers use "rounded-xl" (1.5rem / 24px) to emphasize the soft brand personality.
- **Category Crops:** Product categories (e.g., "Newborn", "Toddler") should be presented in perfect circles or slightly irregular "blob" shapes to mimic hand-drawn elements.
- **Icons:** Icons must have rounded caps and corners. Sharp angles are strictly forbidden.

## Components

- **Primary Buttons:** Solid fill of Mustard (#F2A93B) with Deep Charcoal text. Use a slight "bounce" animation on hover.
- **Secondary Buttons:** Ghost style with a Deep Forest Green border and text.
- **Product Cards:** Use a Cream surface. Photos should feature soft, natural lighting. Price tags should be in the Terracotta accent color.
- **Chips/Size Selectors:** Pill-shaped with a 1px border. Selected state uses a fill of Forest Green with Cream text.
- **Input Fields:** Soft rounded corners with a 1px border. Focus state should use a Mustard glow.
- **Illustrative Elements:** Small hand-drawn elephant icons or stars should be used as decorative "stamps" near headings or inside empty states.
- **Category Navigation:** Circular thumbnails with the category name centered underneath in semi-bold Quicksand.