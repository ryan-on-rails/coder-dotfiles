---
description: Create a pull request with a clear title, summary, and test plan
---

Create a pull request for the current branch. Follow these steps:

1. Run `git status` and `git log main..HEAD --oneline` to understand all commits on this branch
2. Run `git diff main...HEAD --stat` to see what files changed
3. Check if the branch has a remote tracking branch; push if not (`gpsh`)
4. Draft the PR using `gh pr create` with:
   - **Title**: Short, verb-first (under 70 chars). Describe the change, not the ticket.
   - **Body**: Use this format:

```
## What
<!-- 2-3 bullet points describing the change -->

## Why
<!-- The motivation — link to ticket/issue if applicable -->

## Test Plan
<!-- Checklist of how to verify this works -->
- [ ] ...
```

Keep PRs small. If the diff is large (>400 lines), ask before proceeding — the work may need to be split.
