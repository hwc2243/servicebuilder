# Project Instructions

## Source of Truth
- Product requirements: ./docs/PRD.md
- System design: ./docs/DESIGN.md
- Implementation details: ./docs/IMPLEMENTATION.md

## Rules

### 1. Documentation Governance
- Always read the relevant docs in `./docs` before making changes.
- Always follow the architecture and naming conventions in `DESIGN.md`.
- Do not invent features not explicitly defined in `PRD.md`.

### 2. Architectural Constraints
- **Interface-First:** Every component must have an interface. Injections must always use the interface type, never the implementation class.
- **Generation Gap Pattern:** - **Base Components:** Located in `*.base` packages. These are volatile and must be overwritten on every generation.
    - **Extension Components:** These are stable. **NEVER** overwrite these files if they already exist on the file system.
- **Template-Driven:** You are prohibited from generating source code directly. All code generation must be performed by executing FreeMarker templates defined in `./templates`. 
- **Template Modification:** If a change to the generated code structure is required, you must modify the corresponding `.ftl` template rather than the output `.java` file.

### 3. Safety & Confirmation (CRITICAL)
- **Zero-Auto-Write:** You are strictly prohibited from making any changes to the file system without explicit user prompting and confirmation.
- **Preview Protocol:** Before execution, you must present a summary of every file you intend to create or modify.
- **Intervention Loop:** You must wait for a "Yes", "Proceed", or "Commit" response from the user after proposing changes before touching the disk.

## Style
- Keep code concise and easily readable.
- Follow the directory hierarchy and template mapping defined in `IMPLEMENTATION.md`.

## Execution Workflow
1. **Context Load:** Read `./docs/PRD.md` and `./docs/DESIGN.md`.
2. **Analysis:** Identify necessary changes based on the user request and the current file system state.
3. **Permission:** List all proposed file operations (Create/Modify) to the user.
4. **Action:** Execute operations only upon receiving an affirmative confirmation.

## Start Here
- `./docs/PRD.md`
- `./docs/DESIGN.md`
- `./docs/IMPLEMENTATION.md`