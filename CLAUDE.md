# Town OS Website

Astro 5 static site for the Town OS project. Deployed to GitHub Pages at `https://town-os.github.io`.

## Project Structure

```
src/
  layouts/BaseLayout.astro    — Master layout (sticky header, footer, nav, CSS imports)
  pages/                      — All pages (index, guide, concepts, packaging, api, screenshots, community, repositories)
  components/diagrams/        — Diagram components (DiagramFlow, DiagramBox, DiagramArrow, DiagramStack, DiagramLayer, DiagramTag)
  styles/global.css           — CSS variables and base styles
  styles/tailwind.css         — Tailwind theme mapping
public/
  images/logos/               — Logo sizes from 16px to 1024px
  images/screenshots/         — UI screenshots for gallery
  images/banner.png           — Hero background image
```

## Build & Dev

- `make serve` or `bun run astro dev --host 0.0.0.0` for local dev
- `npm run build` for production build to `dist/`
- Requires: Bun (preferred) or Node

## Design Tokens

All colors are CSS variables defined in `src/styles/global.css`:

| Token | Value | Usage |
|---|---|---|
| `--color-bg` | `#0f0f1a` | Page background |
| `--color-bg-elevated` | `#1a1a2e` | Alternating section backgrounds |
| `--color-bg-card` | `#16213e` | Card backgrounds |
| `--color-surface` | `#1e2a4a` | Table headers, surface elements |
| `--color-primary` | `#5b4c9e` | Buttons, accents (purple) |
| `--color-primary-light` | `#7c6bbf` | Button hover state |
| `--color-primary-dim` | `#3d3270` | Subtle borders, hover highlights |
| `--color-accent` | `#a1efe4` | Links, highlights, badges (cyan/teal) |
| `--color-text` | `#f0f0f5` | Primary text |
| `--color-text-muted` | `#a0a0b8` | Secondary/body text |
| `--color-border` | `#2a2a4a` | Borders |
| `--color-code-bg` | `#12121f` | Code block backgrounds |

Tailwind mirrors these as `--color-town-*` in `tailwind.css` (used only in diagram components).

## Style Conventions

### Text & Color
- Use brighter whites for hero/prominent text (`#f0f0f0` for bold leads, `#e0e0e0` for body). Reserve `var(--color-text-muted)` for secondary content.
- When text overlays a background image, wrap it in a container with `rgba(0, 0, 0, 0.4)` background and `border-radius: 12px`. Don't darken the entire image.

### Layout Patterns
- Every section follows: `<section class="section"><div class="container">...</div></section>`
- Alternating sections use `class="section alt-section"` for visual rhythm
- Section titles: `<h2 class="section-title">` with bottom border
- Container max-width: 1200px with 1.5rem horizontal padding

### Cards & Components
- Cards: `.card` class — `var(--color-bg-card)` bg, 1px border, 12px radius, 1.75rem padding
- Buttons: `.btn` base + `.btn-primary` (purple) or `.btn-outline` (cyan border)
- Hover effects: border-color shift + `translateY(-2px)` — consistent across cards, gallery items, callouts

### Content Presentation
- Bold first sentence / paragraph, then present details as a bulleted list
- Custom bullet lists: no default `list-style`, accent-colored `::before` markers, indented with `padding-left`
- Screenshot previews: pull representative shots (Dashboard, Packages, Installation, Services) into a grid linking to the full gallery

### Page Ordering
- Hero first, then visual previews, then calls to action (install commands), then warnings/disclaimers

### Responsive
- Single breakpoint at `768px`
- Grids collapse: 4-col → 2-col, 3-col → 1-col, 2-col → 1-col
- Hero padding reduces, font sizes scale down
- Navigation switches to hamburger menu

### Typography
- System font stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, ...`
- Code font: `'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace`
- Base line-height: 1.7
- Headings: weight 700, line-height 1.3

## CSS Approach
- Scoped `<style>` blocks in each `.astro` file for page-specific styles
- Global reusable classes (`.section`, `.container`, `.card`, `.btn`, etc.) in `global.css`
- Tailwind used only in diagram components — everything else is vanilla CSS
- No utility class sprawl in page markup

## Class Naming
- BEM-like: `.section-title`, `.hero-logo`, `.btn-primary`, `.nav-brand`
- Suffixes: `-section` (containers), `-grid` (layouts), `-card` (cards), `-badge` (badges), `-box` (wrappers), `-banner` (full-width sections)

## JavaScript
- Minimal vanilla JS only — no frameworks
- Navigation toggle and copy-to-clipboard are the only interactive behaviors
- Aria attributes for accessibility on all interactive elements

## General Rules
- No emojis in copy unless explicitly requested
- Images use `loading="lazy"` and `decoding="async"` where appropriate
- All links to external sites get `target="_blank" rel="noopener"`
- Use `import.meta.env.BASE_URL` for all internal links and asset paths
