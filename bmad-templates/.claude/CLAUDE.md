#   CLAUDE.md

GLobally, quoique tu fasse, tu dois toujours le tester et le vérifier, et pour cela tu dois toujours évaluer les tests que tu dois faire pour vérifier ce que tu fais


##  Performance Optimization

###  Model Selection Strategy

**Haiku 4.5** (90% of Sonnet capability, 3x cost savings):
- Lightweight agents with frequent invocation
- Pair programming and code generation
- Worker agents in multi-agent systems

**Sonnet 4.5** (Best coding model):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks

**Opus 4.5** (Deepest reasoning):
- Complex architectural decisions, and document redaction
- for product brief, product management task, architecture tasks
- Maximum reasoning requirements
- Research and analysis tasks

### Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

###  Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis


## Project Overview

Development software using BMAD framework to be built

## Critical Rules

### 0 chain of verification

- any code modification must be tested 
- if any error is detected, it must be corrected
- after correction it must be tested, and so on...

### 1. Code Organization

- Many small files over few large files
- High cohesion, low coupling
- 200-400 lines typical, 800 max per file
- Organize by feature/domain, not by type

### 2. Code Style

- No emojis in code, comments, or documentation
- Immutability always - never mutate objects or arrays
- No console.log in production code
- Proper error handling with try/catch
- Input validation with Zod or similar
- only simple design patter, no complex software architecture
- no complex code syntax, simple is better
- add log at the beginning and the end of each function, class
- always document eveything in the code

### 3. Testing

- TDD: Write tests first
- 80% minimum coverage
- Unit tests for utilities
- Integration tests for APIs
- E2E tests for critical flows
- always integrate logger or alike, to provide easy tracability
- test must be added in the stories when possible
- test-tools 

### 4. Security

- No hardcoded secrets
- Environment variables for sensitive data
- Validate all user inputs
- Parameterized queries only
- CSRF protection enabled

## File Structure

Simple and state of the art file structure consistent with the language used
the file structure of the documentation must clear, avec sub directory for each area of documentation

docs/input/ #docuemnt provided to start the project
docs/brief/ # for product brief document
docs/prd/ # for product requirement description and project manager docuemnt
docs/architecture/ # for all functionnal and technical architecture document
docs/design/ # for all document likend to design UX and UI
docs/epics-stories-tasks
docs/test/ # all strategie de test
docs/tests-results/ # for all tests results
test-tools/ for all tools to execute the tests
src/ #the code
scripts/ # for shell used as tools
prompts/ # referential for all prompts used in the project
configs/ # for all config file used in the projet
test-tools/ # all tools for testing must be gathered at root in:

## Key Patterns

### API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}
```

### Error Handling

```typescript
try {
  const result = await operation()
  return { success: true, data: result }
} catch (error) {
  console.error('Operation failed:', error)
  return { success: false, error: 'User-friendly message' }
}
```

## Environment Variables

```bash
# Required
DATABASE_URL=
API_KEY=

# Optional
DEBUG=false
```

## Available Commands

- `/tdd` - Test-driven development workflow
- `/plan` - Create implementation plan
- `/code-review` - Review code quality
- `/build-fix` - Fix build errors

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never commit to main directly
- PRs require review
- All tests must pass before merge
