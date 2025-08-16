# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Style and Quality Standards

### Core Principles
- Write clean, comprehensive, and rigorous code logic
- Use reasonable and descriptive variable naming
- Apply appropriate function decomposition without over-engineering
- Avoid unnecessary comments for self-evident code

### Function Decomposition Guidelines
- Extract functions when logic is complex, reusable, or conceptually distinct
- **Avoid over-decomposition**: Do not create single-use functions for simple 2-3 line logic blocks
- Functions should have clear, single responsibilities
- Consider reusability and maintainability when deciding to extract functions

### Variable Naming
- Use descriptive names that clearly indicate purpose and content
- Prefer explicit names over abbreviated ones (`userAccount` vs `usrAcc`)
- Use consistent naming conventions throughout the codebase
- Boolean variables should be clearly identifiable (`isActive`, `hasPermission`, `canDelete`)

### Code Comments
- **Do not add comments for obvious code** - let the code speak for itself
- Only add comments for:
  - Complex business logic that requires context
  - Non-obvious algorithms or performance optimizations
  - External API integrations or unusual patterns
  - TODO items or known limitations
- Prefer self-documenting code over explanatory comments

### Code Organization
- Maintain logical code structure and flow
- Group related functionality together
- Use consistent indentation and formatting
- Remove unused imports, variables, and functions
- Ensure proper error handling without over-engineering

### Quality Checklist
Before completing any code changes, ensure:
- [ ] Variable names clearly express their purpose
- [ ] Functions have single, clear responsibilities
- [ ] No unnecessary function extractions for simple logic
- [ ] No comments explaining obvious operations
- [ ] Code is logically organized and easy to follow
- [ ] Error cases are appropriately handled