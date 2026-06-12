# ib_trade_dart Skills Directory

This directory contains prompt-like skills (instructions and blueprints) for the Interactive Brokers Dart SDK.
Skills are structured guides designed to be read by AI agents using the `IsSkillFile: true` option in `view_file` to execute complex tasks consistently.

## Skill Conventions

Each skill file must follow this template:

1. **Header:** Title, category, and target layer.
2. **Pre-requisites:** What other components must be present.
3. **Architecture Check:** Explicit instructions to verify that the implementation adheres to the `.cursorrules` / `.clinerules` / `.antigravityrules` layered architecture.
4. **Step-by-Step Implementation:** Detailed instructions specifying files to create or modify.
5. **Testing/Verification:** Test scenarios and expected behavior.

## Active Skills

| Filename | Description | Target Layer |
|----------|-------------|--------------|
| [base_setup.md](file:///Users/harinikeshr/Documents/2026/projects/ib_trade_dart/.skills/base_setup.md) | Base protocol validation and environment setup. | All |
| [example_add_transport.md](file:///Users/harinikeshr/Documents/2026/projects/ib_trade_dart/.skills/example_add_transport.md) | Blueprint for implementing a new connection transport channel. | Transport Layer |

## Triggering a Skill

To trigger a skill, ask the agent:
> "Trigger the skill in `.skills/<filename>.md`"
