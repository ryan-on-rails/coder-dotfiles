---
name: karpathy-implement
description: "Layer 3 of the Karpathy agentic flow — reads the verified spec and invokes writing-plans then executing-plans. Thin handoff orchestrator with no interactive steps."
user-invocable: true
---

# Karpathy Implement — Layer 3 Handoff

Translate a verified spec into an implementation plan and begin execution. This is a thin orchestrator — no questions, no ceremony.

## Input

Read both `spec.md` and `verify.md` from the run folder. The folder path is passed as args from `karpathy-verify` (a non-empty string like `~/docs/superpowers/specs/2026-06-10-rebuild-auth-flow/`). If args is absent or empty, scan `~/docs/superpowers/specs/` for the most recently modified folder.

## Step 1 — Invoke writing-plans

Before invoking writing-plans, read and display the contents of both `spec.md` and `verify.md` in the conversation so they are visible as context. Then invoke `writing-plans` using the Skill tool.

writing-plans will save its plan to `~/docs/superpowers/plans/`. After writing-plans completes, identify the newly created plan file in `~/docs/superpowers/plans/` (it will be the most recently created `.md` file in that directory) and copy it to the run folder as `plan.md` using Bash.

### Fallback

If writing-plans fails to produce a plan, or if the user rejects the plan and does not proceed, halt and inform the user that implementation cannot begin without an approved plan.

## Step 2 — Invoke executing-plans

After writing-plans completes (its own plan review step is handled internally by writing-plans), immediately invoke `executing-plans` using the Skill tool to begin implementation.
