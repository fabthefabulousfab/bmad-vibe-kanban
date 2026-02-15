# Story 2-1/2: Create Architecture Diagrams

**Wave:** 2 | **Epic:** 1 | **Story:** 2
**Status:** Ready for Development

## User Story

**As a** developer defining system architecture,
**I want** to create visual architecture diagrams in Excalidraw format,
**So that** the architecture is documented and shareable with the team.

## Acceptance Criteria

1. [ ] System architecture diagram created
2. [ ] Component relationships visualized
3. [ ] ERD or data model diagram (if applicable)
4. [ ] Diagrams saved in `.excalidraw` format

## BMAD Workflow

**Type:** Manual Task (No automated workflow)

**Process:**
1. Open Excalidraw (excalidraw.com or local)
2. Create diagrams based on architecture document
3. Save to planning-artifacts/diagrams/

**Reference Input:**
- `_bmad-output/planning-artifacts/architecture.md`
- PRD (for system context)

**Output:** `_bmad-output/planning-artifacts/diagrams/`
- `system-architecture.excalidraw`
- `component-diagram.excalidraw`
- `erd.excalidraw` (if data model exists)

**Validation:** Diagrams are viewable in Excalidraw and match architecture document

**Note:** Diagrams should be created during architecture phase (Wave 2), NOT after development. They serve as inputs for implementation, not post-facto documentation.

### Diagram Types

**System Architecture:**
- Components and their interactions
- External dependencies
- Data flow

**Component Diagram:**
- Internal modules/packages
- Component relationships
- API boundaries

**ERD (if applicable):**
- Database schema
- Entity relationships
- Key constraints

### Checklist
- [ ] Command executed
- [ ] Diagram files generated
- [ ] Diagrams validated against architecture

## Definition of Done
- [ ] All diagrams created in Excalidraw format
- [ ] Diagrams accurately reflect architecture
- [ ] Files committed to repository
- [ ] Diagrams referenced in architecture document
