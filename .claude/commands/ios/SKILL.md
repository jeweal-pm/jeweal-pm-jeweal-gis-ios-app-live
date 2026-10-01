---
name: ios
description: Short-form entry point for any iOS UI work in the GIS app (Swift/UIKit, storyboard-first) — figures out on its own whether the request is a brand-new screen/component (routes to create-ui) or a change to something that already exists (routes to edit-ui) by searching the codebase first, then hands off to that skill's full workflow. Use this when the user gives a short or ambiguous UI request (e.g. "ios <description>") and doesn't say explicitly whether to create or edit, or whenever it's unclear if the requested screen/component already exists.
---

# ios — auto create/edit router for iOS UI work

This skill does not implement UI work itself. Its only job is to figure out,
before anything is built, whether the request is actually a **create-ui**
task or an **edit-ui** task — then hand off to that skill's full workflow
(clarifying questions, style-matching, tests, changelog, chatlog upload all
still apply from there, unchanged).

## Step 0 — read context

Check the current session's conversation for a design, screen name, or
requirement already discussed before this skill was invoked. Don't make the
user repeat it.

## Step 1 — identify the target

Extract the name/keywords of the screen, component, or flow being asked
about (e.g. "reserve note suggestion", "linked order", "SKU product
summary"). If it's genuinely unclear what's being requested, ask one short
question before searching — don't guess a name to search for.

## Step 2 — search the codebase for an existing match

Before deciding create vs. edit, actually check whether it already exists:

- Glob `GIS/**/*.storyboard` and `GIS/**/*.swift` for filenames matching the
  keywords or feature name (this app is organized as one folder + one
  storyboard per feature, e.g. `GIS/Pos/` + `pos.storyboard`,
  `GIS/Catalog/` + `catalog.storyboard`).
- Grep view controller class names and scene/segue identifiers for the
  keywords — a matching screen can live under a differently-worded file
  name than the request used.
- Check localized string keys under `GIS/Base.lproj/` for matching copy —
  existing UI text is often the fastest confirmation a screen already
  exists.
- Check `GIS/CommonModals/Controllers/` specifically — many flows reuse a
  shared modal/controller. A screen that looks "new" in the request might
  actually be that shared controller opened in a new context, which is an
  **edit** to the shared controller, not a new create.
- If the user named a specific existing screen/feature folder, open it and
  confirm what's actually implemented there rather than trusting the name
  alone.

## Step 3 — decide, state the evidence, then hand off

- **Match found** (the screen/component/flow already exists, even
  partially) → this is an **edit**. Tell the user what you found and where
  (file paths), then read and follow `.claude/skills/edit-ui/SKILL.md` for
  the rest of this task.
- **No match** → this is a **create**. Tell the user you searched and found
  nothing matching (name the places you checked), then read and follow
  `.claude/skills/create-ui/SKILL.md` for the rest of this task.
- **Ambiguous** (a similarly-named screen exists but may be a different
  feature, or the match is partial) → ask the user one short question
  (e.g. "Found `GIS/Reserve/ReserveNote.swift` — is this the screen you
  mean, so this is an edit? Or is this a separate new screen?") before
  proceeding. Don't silently guess between create and edit when it's
  genuinely unclear — a wrong guess here means the wrong workflow runs for
  the whole task.

Always state which mode was picked and why, up front, before starting real
work — so the user can redirect immediately if the detection was wrong.

## Notes

- Typing `/ios <what you want>` invokes this router directly — that's the
  short form. `/create-ui` and `/edit-ui` are still available directly when
  the user already knows which one they want and wants to skip the search
  step.
- This skill must not duplicate create-ui/edit-ui's rules here — if those
  files change, this router should not need to change, since it only
  decides which one to follow.
