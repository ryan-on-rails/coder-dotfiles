---
name: karpathy-spec
description: "Layer 1 of the Karpathy agentic flow — transforms a Jira ticket or free-form task description into a tight, precisely scoped spec via structured interview. Auto-chains to karpathy-verify on completion."
user-invocable: true
---

# Karpathy Spec — Layer 1

Transform a Jira ticket or free-form task into a tight spec. This is the first phase of the Karpathy three-layer prompting method.

## Input Detection

Check args passed to this skill:
- **Jira URL**: matches `https://[^/]+\.atlassian\.net/browse/[A-Z]+-\d+`
- **Jira key**: matches pattern like `PROD-123` or `ENG-456` (letters, dash, digits)
- **Free-form**: anything else

For Jira inputs, use the Atlassian MCP tool to fetch the ticket. Extract: title, description, acceptance criteria, priority. If the Atlassian MCP fetch fails, use the URL or key as the task title and note '(Jira fetch failed — using key as title)' in the summary.

## Step 1 — Ingest and Summarize

Display a one-paragraph summary of what was received. Ask the user to confirm this is correct before proceeding. Do not ask any interview questions yet. If the user says the summary is wrong, ask what needs correcting and revise. If they want to cancel entirely, exit the skill.

## Step 2 — Interview

Ask at most 5 questions, **one at a time**. When in doubt about whether a question is still needed, ask it. Only skip a question if a prior answer has already fully answered it.

Ask in this order:
1. What is the actual goal behind this task — what decision or outcome does it drive, beyond just the deliverable?
2. What context does Claude need that isn't in the description? (dependencies, constraints, non-obvious assumptions, things that have failed before)
3. What does "done" look like to you? How will you know it succeeded?
4. What is explicitly NOT in scope for this task?
5. What would make you reject the output even if it technically meets the description?

## Step 3 — Write spec.md

Create a run folder: `~/docs/superpowers/specs/YYYY-MM-DD-<slug>/`
- Use today's date in YYYY-MM-DD format
- Slug: 3-5 word kebab-case derived from the task title. Example: 'Rebuild authentication flow with OAuth2' → `rebuild-auth-flow-oauth2`. Remove special characters, lowercase everything.

Write `spec.md` inside that folder:

```
# Spec: [Task Title]

## Goal
[The outcome or decision being driven — not just the deliverable]

## Context
[Background, dependencies, constraints, non-obvious assumptions]

## Scope

**In scope:**
- [item]

**Out of scope:**
- [item]

## Success Criteria
- [Concrete, measurable criterion — specific behavior, not vague quality]

## Key Constraints
- [Hard limits Claude must not violate]
```

## Step 4 — Auto-chain to karpathy-verify

After writing spec.md, immediately invoke the `karpathy-verify` skill using the Skill tool. Invoke karpathy-verify with the full folder path as args, e.g.: `~/docs/superpowers/specs/2026-06-10-rebuild-auth-flow/`
