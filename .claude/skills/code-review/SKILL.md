---
name: code-review
description: Review the current diff or a specific PR for bugs, security issues, performance problems, and Rails best practices. Use when asked to review code, check a PR, or audit recent changes.
user-invocable: true
---

Review the code changes and provide actionable feedback. Focus on substance — skip praise, skip style issues that rubocop handles.

## What to look for

**Bugs & correctness**
- Off-by-one errors, nil handling, missing validations
- Race conditions in background jobs or concurrent requests
- Incorrect ActiveRecord queries (N+1, missing includes, wrong scoping)

**Security**
- Mass assignment without strong params
- SQL injection via string interpolation
- Sensitive data logged or exposed in responses
- Missing authorization checks (Pundit/CanCan policy coverage)

**Performance**
- N+1 queries — flag any association access inside loops
- Missing database indexes on foreign keys or commonly queried columns
- Synchronous work that should be a background job

**Rails conventions**
- Fat controllers (logic should live in models/services)
- Callbacks with hidden side effects
- Direct column access vs. delegated methods
- Test coverage: are happy path AND edge cases covered?

## How to run

1. If reviewing a PR: `gh pr diff <number>` then review the output
2. If reviewing recent commits: `git diff main...HEAD`
3. If reviewing specific files: read them directly

Output findings as a numbered list ordered by severity (critical → suggestion). For each issue include the file/line, what the problem is, and a concrete fix.
