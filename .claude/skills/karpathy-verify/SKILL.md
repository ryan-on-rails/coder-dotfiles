---
name: karpathy-verify
description: "Layer 2 of the Karpathy agentic flow — defines evaluation criteria, runs a critic subagent to find spec holes, resolves findings, then presents a manual gate before handing off to karpathy-implement."
user-invocable: true
---

# Karpathy Verify — Layer 2

Stress-test the spec before implementation begins. This is the second phase of the Karpathy three-layer prompting method.

## Input

Read `spec.md` from the run folder. The folder path is passed as args from `karpathy-spec`. If args is provided (non-empty string), use it as the run folder path. If args is absent or empty, scan `~/docs/superpowers/specs/` for the most recently modified folder.

## Step 1 — Derive Evaluation Criteria

From the spec, extract precise, measurable pass/fail criteria. Each criterion must name specific expected behavior — not vague quality judgments.

**Bad:** "handles errors correctly"
**Good:** "returns HTTP 422 with `{error: string, field: string}` body when a required field is missing"

Present the criteria to the user. Ask: "Do these criteria look right? Add, remove, or adjust anything before I run the critic."

Wait for explicit confirmation before proceeding to Step 2.

## Step 2 — Spawn Critic Subagent

Use the Agent tool with `subagent_type: general-purpose` to spawn the critic subagent. Populate the prompt with the actual content of spec.md and the confirmed criteria:

```
You are a spec critic. Your only job is to find problems.

Here is a software spec and its evaluation criteria. Find:
- Holes in the requirements (things that need to happen but aren't stated)
- Bad assumptions (things the spec assumes that may not be true)
- Missing context (information an implementer would need but doesn't have)
- Ambiguities (requirements that could be interpreted two different ways)
- Anything that would cause an implementation to fail or miss the actual goal

Return exactly two lists:
**BLOCKERS** — must be resolved before implementation begins
**SUGGESTIONS** — worth fixing but not blocking

Be specific. No vague feedback like "consider edge cases." Name the specific edge case.

---
SPEC:
[full contents of spec.md]

EVALUATION CRITERIA:
[confirmed criteria from Step 1]
```

## Step 3 — Present and Resolve Findings

Show the critic's output to the user.

For each **BLOCKER**:
- User either provides clarification inline (Claude incorporates it), or
- Claude proposes a spec.md edit and waits for user approval before writing it

For each **SUGGESTION**:
- User accepts → update `spec.md`
- User dismisses → note the reason

All blockers must be resolved before proceeding to Step 4. If a blocker cannot be resolved, halt and ask the user for guidance before proceeding.

## Step 4 — Write verify.md

Save `verify.md` in the same folder as `spec.md`:

```
# Verification: [Task Title]

## Evaluation Criteria
[final criteria after user adjustments]

## Critic Findings

### Blockers Resolved
- **[blocker]:** [resolution or spec update made]

### Suggestions Accepted
- **[suggestion]:** [change made to spec]

### Suggestions Dismissed
- **[suggestion]:** [reason dismissed]
```

## Step 5 — Manual Gate

Present this message exactly:

> "Spec verified. Ready to proceed to implementation? (yes/no)"

- **yes** → invoke `karpathy-implement` using the Skill tool, passing the run folder path as args (same format as karpathy-spec used: full folder path string, e.g. `~/docs/superpowers/specs/2026-06-10-rebuild-auth-flow/`)
- **no** → stop and wait for further instructions
