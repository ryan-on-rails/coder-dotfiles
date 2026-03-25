---
name: rpi
description: Research, Plan, Implement — a structured workflow for implementing a feature or fixing a non-trivial bug. Use this when the task involves multiple files, uncertain scope, or architectural decisions.
user-invocable: true
---

Execute the Research → Plan → Implement workflow in three gated phases.

## Phase 1: Research

Before writing any code:
- Read relevant files, routes, models, controllers, specs
- Identify existing patterns to follow (don't invent new ones if one exists)
- Understand the full scope — what files will change, what tests exist
- Identify gotchas: callbacks, validations, background jobs, API contracts

Output a `RESEARCH.md` in the current directory summarizing:
- What you found
- The approach you'll take
- Risks or unknowns
- A GO / NO-GO recommendation

Stop and wait for confirmation before proceeding to Phase 2.

## Phase 2: Plan

Create a `PLAN.md` in the current directory with:
- Ordered list of changes (file-by-file)
- What tests need to be written or updated
- Any migrations, seeds, or data changes
- Definition of done — how to verify it works

Keep phases small enough that each one can be verified independently.

Stop and wait for confirmation before proceeding to Phase 3.

## Phase 3: Implement

Execute the plan phase by phase:
- After each phase, run the relevant tests (`rspec path/to/spec`)
- Run `rubocop -a` on changed Ruby files
- Only proceed to the next phase after tests pass
- If something unexpected comes up, stop and surface it rather than improvise

After all phases complete, provide a summary of what changed and how to test it end-to-end.
