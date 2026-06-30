---
name: github-review-queue
description: Use when the user wants to check their pending GitHub PR review requests, work through their review queue, or process pull requests assigned to them for review. Specifically targets the RoadRunnerEngineering organization.
user-invocable: true
---

# GitHub Review Queue

## Overview

Fetch the 3 most recent open PRs where the user has been requested as a reviewer in RoadRunnerEngineering, then walk through each one collaboratively.

## Step 1 — Fetch the Queue

Run this command and parse the JSON:

```bash
gh search prs --review-requested=@me --owner=RoadRunnerEngineering --state=open --limit=3 --sort=updated --json number,title,url,author,updatedAt,commentsCount,repository
```

Present the results as a numbered overview before diving in:

```
Review Queue (3 PRs)
────────────────────
1. [#13261] Replace NaN with N/A in Service Replacements — coyote — mneedleman — updated 2h ago
2. [#15] Add eng-ops-git plugin — rr-skills — ianhgraham-rr — updated 5h ago
3. [#19] Add eng-ops-tracking plugin — rr-skills — ianhgraham-rr — updated 2d ago
```

## Step 2 — Work Through Each PR

For each PR **one at a time**:

1. **Show PR details** — run `gh pr view <number> --repo <owner/repo>` to get the description, labels, and status checks.
2. **Present the options:**

```
PR #<number>: <title>
Repo: <owner/repo> | Author: <login> | Comments: <n>
URL: <url>

How would you like to handle this?
  [1] Full review  — read the diff and give structured feedback
  [2] Approve      — approve with an optional comment
  [3] Skip         — move on, review later
  [4] Comment      — leave a comment without a formal review decision
  [5] Open in browser
```

3. **Execute the decision:**

| Choice | Command |
|--------|---------|
| Full review | Run `/code-review`, pointing it at `gh pr diff <number> --repo <owner/repo>` |
| Approve | `gh pr review <number> --repo <owner/repo> --approve --body "<comment>"` |
| Request changes | `gh pr review <number> --repo <owner/repo> --request-changes --body "<feedback>"` |
| Comment only | `gh pr review <number> --repo <owner/repo> --comment --body "<comment>"` |
| Open in browser | `open <url>` |

4. Confirm the action completed, then move to the next PR.

## Step 3 — Wrap Up

After all 3 PRs, summarize what was handled:

```
Done. Queue summary:
  ✓ #13261 — Approved
  ✓ #15    — Reviewed (requested changes)
  → #19    — Skipped
```

## Notes

- If the queue returns fewer than 3 PRs, proceed with what's there.
- For full reviews, `/code-review` handles Rails/Ruby best practices, security, and N+1 checks — no need to re-explain that criteria here.
- Always confirm destructive actions (approve/request-changes) before running the `gh pr review` command.
