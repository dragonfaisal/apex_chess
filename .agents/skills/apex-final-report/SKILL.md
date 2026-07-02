---
name: apex-final-report
description: Use at the end of every Apex Chess agent task to report files changed, behavior changed, tests run, evidence, skipped validations, limitations, and next action.
---

# apex-final-report

## Trigger phrases

- final report
- summarize work
- completion report
- handoff
- done
- validation evidence

## When to use

Use at the end of every Apex implementation, QA, workflow, docs, skill, audit, or review task.

## When NOT to use

Do not use for mid-task planning updates or while implementation/validation is still in progress.

## Instructions

1. Be concise and factual.
2. List exact files created, modified, or deleted.
3. Separate behavior changes from workflow/docs-only changes.
4. Name exact validation commands and results.
5. If validation was skipped, explain why.
6. Do not overclaim production readiness.
7. Include known limitations.
8. End with one precise next action.

## Required output format

```markdown
FILES CREATED:

* <path or None>

FILES MODIFIED:

* <path or None>

BEHAVIOR CHANGED:

* <runtime/product behavior, or None>

VALIDATION:

* <command>: <result>

SKIPPED VALIDATIONS:

* <validation> - <reason>

KNOWN LIMITATIONS:

* <limitation or None known>

NEXT ACTION:

<one precise next action>
```
