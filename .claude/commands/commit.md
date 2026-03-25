---
description: Create a well-structured git commit with a clear message
---

Review all staged and unstaged changes, then create a commit following these steps:

1. Run `git status` and `git diff` to understand all changes
2. Run `git log --oneline -5` to match the existing commit message style
3. Stage relevant files with `git add` (avoid `.env`, secrets, or unrelated files)
4. Write a commit message that:
   - Starts with a verb: Add, Fix, Update, Remove, Refactor, etc.
   - Describes the *why*, not just the *what*
   - Is concise (under 72 chars for the subject line)
   - Uses a body paragraph if the change needs more context
5. Create the commit — no co-author lines

Do NOT commit if there are no changes, obvious secrets present, or if the changes are incomplete/broken.
