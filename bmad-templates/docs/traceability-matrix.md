# Traceability Matrix

**Last Updated:** 2026-02-05

## Overview

This matrix traces requirements (FRs) through implementation (stories, code, tests).

## Epic 1: Foundation - Shared Library & Story Templates

### Story 1.1.1: Shared Common Library

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/1.1-common-library.md` | Complete |
| Implementation | `scripts/lib/common.sh` | Complete |
| Tests | `test-tools/common.bats` | 7/7 PASS |
| Test Review | `_bmad-output/reviews/test-review-1.1.1.md` | Score: 95 |
| Code Review | `_bmad-output/reviews/code-review-1.1.1.md` | Score: 92 |

**FRs Covered:** Part of FR15-FR18 (story content/structure)

### Story 1.1.2: Shared API Library

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/1.2-api-library.md` | Complete |
| Implementation | `scripts/lib/api.sh` | Complete |
| Tests | `test-tools/api.bats` | 11/11 PASS |
| Test Review | `_bmad-output/reviews/test-review-1.1.2.md` | Score: 90 |
| Code Review | `_bmad-output/reviews/code-review-1.1.2.md` | Score: 88 |

**FRs Covered:** FR11 (API connection), FR23 (deduplication)

### Stories 1.1.3-1.1.6: Pre-Generated Story Files

| Workflow | Files | Location | Status |
|----------|-------|----------|--------|
| WORKFLOW_COMPLET | 16 | `stories/workflow-complet/` | Complete |
| DOCUMENT_PROJECT | 8 | `stories/document-project/` | Complete |
| QUICK_FLOW | 7 | `stories/quick-flow/` | Complete |
| DEBUG | 7 | `stories/debug/` | Complete |

**FRs Covered:** FR4-FR7 (story import), FR15-FR18 (story content)

### Epic 1 Summary

| Metric | Value |
|--------|-------|
| Stories | 6/6 Complete |
| Unit Tests | 18/18 PASS |
| Story Files | 38 + 1 template |
| FIN EPIC | Complete |

---

## Epic 2: Workflow Selection & BMAD Story Import

### Story 2.1: Workflow Questionnaire

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/2.1-workflow-questionnaire.md` | Complete |
| Implementation | `scripts/import-bmad-workflow.sh` | Complete |
| Tests (Unit) | `test-tools/questionnaire.bats` | 14/14 PASS |
| Tests (Integration) | `test-tools/import-workflow.bats` | 10/10 PASS |
| Test Review | `_bmad-output/reviews/test-review-2.1.md` | Score: 93 |
| Code Review | `_bmad-output/reviews/code-review-2.1.md` | Score: 90 |

**FRs Covered:** FR1 (questionnaire), FR2 (4 workflow types), FR3 (QUICK_FLOW eligibility)

### Story 2.2: Vibe Kanban Project Selection

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/2.2-project-selection.md` | Complete |
| Implementation | `scripts/import-bmad-workflow.sh` (updated) | Complete |
| Tests | `test-tools/project-selection.bats` | 10/10 PASS |
| Test Review | `_bmad-output/reviews/test-review-2.2.md` | Score: 90 |
| Code Review | `_bmad-output/reviews/code-review-2.2.md` | Score: 88 |

**FRs Covered:** FR14 (project association), FR22 (prerequisites check), FR25 (error messages)

### Story 2.3-2.6: Workflow Import

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/2.3-workflow-import.md` | Complete |
| Implementation | `scripts/lib/story-parser.sh` | Complete |
| Implementation | `scripts/import-bmad-workflow.sh` (updated) | Complete |
| Tests | `test-tools/story-import.bats` | 12/12 PASS |

| Story | Workflow | Stories | Status |
|-------|----------|---------|--------|
| 2.3 | WORKFLOW_COMPLET | 15 | Complete |
| 2.4 | DOCUMENT_PROJECT | 8 | Complete |
| 2.5 | QUICK_FLOW | 7 | Complete |
| 2.6 | DEBUG | 7 | Complete |

**FRs Covered:** FR4-FR7 (import stories), FR12 (ordering), FR13 (status)

### Story 2.7: Deduplication

| Artifact | Location | Status |
|----------|----------|--------|
| Story | - | Complete (integrated) |
| Implementation | `scripts/lib/api.sh` | Complete |
| Implementation | `scripts/lib/story-parser.sh` | Complete |
| Tests | `test-tools/api.bats`, `test-tools/story-import.bats` | Covered |

**FRs Covered:** FR23 (skip duplicates), FR24 (safe re-run), FR25 (error messages)

### Epic 2 Summary

| Metric | Value |
|--------|-------|
| Stories | 7/7 Complete |
| Unit Tests | 54/54 PASS |
| Integration Tests | 11/11 PASS |
| FIN EPIC | Complete |

---

## Epic 3: Project Story Import

### Story 3.1-3.3: Project Story Import

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/3.1-parse-project-stories.md` | Complete |
| Implementation | `scripts/lib/project-story-parser.sh` | Complete |
| Implementation | `scripts/import-project-stories.sh` | Complete |
| Tests | `test-tools/project-stories.bats` | 15/15 PASS |
| Test Review | `_bmad-output/reviews/test-review-3.1.md` | Score: 90 |
| Code Review | `_bmad-output/reviews/code-review-3.1.md` | Score: 93 |

**FRs Covered:** FR8 (import project stories), FR9 (parse X.Y.Z), FR10 (extract metadata)

### Epic 3 Summary

| Metric | Value |
|--------|-------|
| Stories | 3/3 Complete |
| Unit Tests | 15/15 PASS |
| FIN EPIC | Pending |

---

## Epic 4: Self-Extracting Installer & Distribution

### Story 4.1-4.3: Build and Install

| Artifact | Location | Status |
|----------|----------|--------|
| Story | `_bmad-output/stories/4.1-build-installer.md` | Complete |
| Implementation | `scripts/build-installer.sh` | Complete |
| Generated | `install-bmad-vibe-kanban.sh` | Complete |
| Tests | `test-tools/build-installer.bats` | 9/9 PASS |
| Test Review | `_bmad-output/reviews/test-review-4.1.md` | Score: 84 |
| Code Review | `_bmad-output/reviews/code-review-4.1.md` | Score: 99 |

**FRs Covered:** FR19-FR21 (installation), FR26-FR31 (build/packaging)

### Epic 4 Summary

| Metric | Value |
|--------|-------|
| Stories | 3/3 Complete |
| Unit Tests | 9/9 PASS |
| FIN EPIC | Pending |

---

## FR Coverage Summary

| FR | Description | Epic | Story | Status |
|----|-------------|------|-------|--------|
| FR1 | Questionnaire | 2 | 2.1 | COMPLETE |
| FR2 | 4 workflow types | 2 | 2.1 | COMPLETE |
| FR3 | QUICK_FLOW eligibility | 2 | 2.1 | COMPLETE |
| FR4 | WORKFLOW_COMPLET import | 2 | 2.3 | COMPLETE |
| FR5 | DOCUMENT_PROJECT import | 2 | 2.4 | COMPLETE |
| FR6 | QUICK_FLOW import | 2 | 2.5 | COMPLETE |
| FR7 | DEBUG import | 2 | 2.6 | COMPLETE |
| FR11 | API connection | 1 | 1.2 | COMPLETE |
| FR12 | Task ordering | 2 | 2.3-2.6 | COMPLETE |
| FR13 | Task status | 2 | 2.3-2.6 | COMPLETE |
| FR14 | Project association | 2 | 2.2 | COMPLETE |
| FR15 | Story title | 1 | 1.3-1.6 | COMPLETE |
| FR16 | BMAD workflow path | 1 | 1.3-1.6 | COMPLETE |
| FR17 | Story description | 1 | 1.3-1.6 | COMPLETE |
| FR18 | X.Y.Z ordering | 1 | 1.3-1.6 | COMPLETE |
| FR8 | Import project stories | 3 | 3.1 | COMPLETE |
| FR9 | Parse X.Y.Z format | 3 | 3.1 | COMPLETE |
| FR10 | Extract story metadata | 3 | 3.2 | COMPLETE |
| FR19 | Single shell script installation | 4 | 4.2 | COMPLETE |
| FR20 | Installer extracts embedded files | 4 | 4.2 | COMPLETE |
| FR21 | Auto-run workflow import | 4 | 4.2 | COMPLETE |
| FR22 | Prerequisites check | 1 | 1.1 | COMPLETE |
| FR23 | Skip duplicates | 1,2 | 1.2, 2.7 | COMPLETE |
| FR24 | Safe re-run | 2 | 2.7 | COMPLETE |
| FR25 | Error messages | 1,2 | 1.1, 2.1 | COMPLETE |
| FR26 | Embed _bmad/ directory | 4 | 4.1 | COMPLETE |
| FR27 | Embed .claude/ directory | 4 | 4.1 | COMPLETE |
| FR28 | Regenerate when _bmad changes | 4 | 4.1 | COMPLETE |
| FR29 | Regenerate when .claude changes | 4 | 4.1 | COMPLETE |
| FR30 | Regenerate when format changes | 4 | 4.1 | COMPLETE |
| FR31 | Provide build-installer.sh | 4 | 4.1 | COMPLETE |

**Coverage:** 31/31 FRs COMPLETE (100%)

---

## Test Summary

| Category | Tests | Passing | Notes |
|----------|-------|---------|-------|
| Unit (common.bats) | 7 | 7 | |
| Unit (api.bats) | 11 | 11 | |
| Unit (questionnaire.bats) | 14 | 14 | 5-option flow |
| Unit (project-selection.bats) | 10 | 10 | |
| Unit (story-import.bats) | 12 | 12 | Story 2.3-2.6 |
| Unit (project-stories.bats) | 15 | 15 | Story 3.1-3.3 |
| Integration (import-workflow.bats) | 11 | 11 | 5-option flow |
| Integration (build-installer.bats) | 9 | 9 | Story 4.1-4.3 |
| **Total** | **89** | **89 active** | |
