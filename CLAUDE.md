# Momens iOS — Claude Code

The shared agent guide lives in AGENTS.md. Follow it for all work in this repository.

@AGENTS.md

## Claude Code Notes

- Skills are not auto-loaded from `.agents/`. Before SwiftUI work, read `.agents/.skills/momens-ios/SKILL.md` and its references. Before task/branch/commit/PR work, read `.agents/.skills/momens-workflow/SKILL.md`.
- Project subagents live in `.claude/agents/` (`momens-explorer`, `momens-reviewer`, `code-reviewer`, `pr-writer`). All of them are read-only.
- Build check: `xcodebuild -scheme momens-ios -destination 'generic/platform=iOS Simulator' build`
- Lint check: `swiftlint lint`
