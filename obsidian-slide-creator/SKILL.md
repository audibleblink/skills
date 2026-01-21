---
name: obsidian-slide-creator
description: Create presentation slide decks for Obsidian Slides Extended (reveal.js wrapper). Use when the user requests slide generation, presentation creation, or converting content to slides. Handles multiple input formats including outlines, topic descriptions, existing markdown, and interactive planning. Always uses the 'blood' theme.
---

# Obsidian Slide Creator

## Overview

Generate professional presentation slide decks formatted for Obsidian Slides Extended, a plugin that wraps reveal.js. This skill handles all slide generation scenarios: from outlines, topic descriptions, existing content, or through interactive planning.

## Generation Workflow

### Step 1: Understand Requirements

Determine the input type:

**From outline/bullets:**
- User provides structured outline
- Convert hierarchy to slide structure
- Maintain logical flow

**From topic description:**
- User describes topic and key points
- Ask clarifying questions about:
  - Duration/depth of presentation
  - Target audience
  - Key messages to emphasize
- Structure content appropriately

**From existing markdown:**
- User has markdown content
- Reformat for slide syntax
- Add appropriate separators and fragments

**Interactive planning:**
- Collaborate with user to build slides
- Propose structure, get feedback
- Iterate on content and organization

### Step 2: Structure the Presentation

Apply this standard structure:

1. **Title slide** - Main topic
2. **Agenda slide** - Overview with vertical sub-slides for each section
3. **Main sections** - One per major topic (horizontal slides)
4. **Detail slides** - Vertical slides under main sections for depth
5. **Takeaways** - Summary of key points
6. **Questions/Resources** - Final slide

### Step 3: Apply Slide Syntax

**Frontmatter (required):**
```yaml
---
title: Presentation Title
areas: 
  - "[[Topic|📍 Topic]]"
tags: 
  - resource/reference
archived: false

hash: true
theme: blood
verticalSeparator: xxx
---
```

**Slide separators:**
- `---` for horizontal slides (main sections)
- `xxx` for vertical slides (sub-topics, details)

**Progressive reveals:**
- Use `-` for immediately visible list items
- Use `+` for items that appear on click

**Speaker notes:**
```markdown
notes:
  Context and talking points for the presenter
```

**Navigation helpers:**
```markdown
**Next topic** <i class="fa-solid fa-arrow-right"></i>

**Deeper**
<i class="fa-solid fa-arrow-down"></i>
```

### Step 4: Content Guidelines

**Keep slides focused:**
- One main idea per slide
- Use vertical slides for details/examples
- Avoid overcrowding

**Use progressive disclosure:**
- Start with main points (visible immediately)
- Add supporting details with `+` notation
- Build complexity gradually

**Add speaker notes:**
- Include context not visible on slides
- Provide talking points
- Note important transitions

**Structure for flow:**
- Horizontal slides = major sections
- Vertical slides = drilling into topics
- Use navigation indicators

## Common Patterns

**See [patterns.md](references/patterns.md) for detailed examples of:**
- Title slides
- Agenda structure
- Content slides (bullets, code, images)
- Deep dive pattern (vertical slides)
- Comparison slides
- Takeaways and questions

## Full Syntax Reference

**For complete syntax details, see [syntax.md](references/syntax.md)**, which covers:
- All slide separators
- Frontmatter options
- Fragment notation
- Speaker notes
- Code blocks with highlighting
- Layout components (split, grid)
- Backgrounds and styling
- Special features (stacks, animations)

## Template

**Use [template.md](assets/template.md)** as a starting point for standard presentations. It includes:
- Proper frontmatter structure
- Agenda with sections
- Example slides with notes
- Navigation indicators
- Common patterns pre-formatted

## Output Format

Always output the complete markdown file ready to use in Obsidian. Ensure:

1. Frontmatter is complete and valid
2. Slide separators are correct (`---` and `xxx`)
3. Fragment notation (`+`) is used appropriately
4. Speaker notes are included for guidance
5. Navigation indicators are present where helpful
6. Theme is set to `blood`

## Example Usage

**User:** "Create a slide deck about Docker basics for beginners, covering containers, images, and basic commands"

**Assistant approach:**
1. Ask about presentation duration and depth
2. Structure: Title → Agenda → What is Docker → Containers → Images → Commands → Takeaways
3. Use vertical slides for details under each main topic
4. Add code examples with syntax highlighting
5. Include speaker notes with context
6. Add progressive reveals for key points

**User:** "Convert this outline into slides: [outline content]"

**Assistant approach:**
1. Parse outline hierarchy
2. Map top-level items to horizontal slides
3. Map sub-items to vertical slides or fragments
4. Add proper frontmatter and separators
5. Enhance with speaker notes

## Tips

- **Use vertical slides liberally** - They're perfect for drilling into details without cluttering the main flow
- **Always add speaker notes** - Even brief notes help presenters remember context
- **Leverage fragments** - Progressive reveals keep audience focused on current point
- **Balance content** - If a slide feels crowded, split into multiple vertical slides
- **Test the structure** - Ensure horizontal flow makes sense for main narrative, vertical provides depth
