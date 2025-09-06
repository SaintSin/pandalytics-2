# Claude Code Archiving Instructions

## Analytics Component Versioning

When making significant changes to `src/components/page/Analytics.astro`, create versioned copies to track evolution and identify where bugs were introduced.

### Process

1. **Create versioned copy** in `src/components/page/versions/`
2. **Naming convention**: `Analytics-v{number}-{brief-description}.astro`
3. **Add comprehensive annotations** at the top of each version file

### Required Annotations

Each archived version must include:

```javascript
---
// ANALYTICS VERSION X - BRIEF DESCRIPTION
// Date: YYYY-MM-DD or conversation context
// Status: WORKING/PROBLEMATIC/BREAKTHROUGH/etc
// Changes from VX:
// - Key change 1
// - Key change 2
// Issues Fixed:
// - ✅ Fixed issue description
// Remaining Issues:
// - ❌ Outstanding issue description
// Key Technical Insights:
// - Important learnings or breakthroughs
---
```

### Version History

Maintain `src/components/page/versions/README.md` with:

- Timeline of all versions
- Status summary for each version
- Key technical learnings
- Current status and next steps

### Purpose

This systematic versioning helps:

- Track component evolution over time
- Identify exactly where bugs were introduced
- Document technical breakthroughs and learnings
- Enable easy comparison between working and broken states
- Provide context for complex iterative development

### Example Structure

```
src/components/page/versions/
├── Analytics-v1-original-complex.astro
├── Analytics-v2-stripped-basics.astro
├── Analytics-v3-hybrid-approach.astro
├── Analytics-v4-browser-detection.astro
├── Analytics-v5-time-based-deduplication.astro
├── Analytics-v6-current-with-error.astro
└── README.md
```

This approach is especially valuable for components that undergo significant iterative development with multiple technical challenges and breakthroughs.
