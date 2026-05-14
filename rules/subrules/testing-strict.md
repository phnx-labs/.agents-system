# Strict Testing

- **Test file = source file, 1:1.** `read.go` → `read_test.go`, `parser.ts` → `parser.test.ts`.
- **Tests live in the codebase, not `/tmp`.** Fixtures in `testdata/` near source.
- **No mocking.** Real services only. Tests must exercise the actual critical path.
- **Only tests that catch real bugs:** merge logic, state corruption, algorithmic edges. Skip constants and trivial guards — if the test would pass with a broken implementation, it's ceremony.
- **Unit tests are necessary, not sufficient.** Verify end-to-end (core-hard-lines #1).

## Design before code

Before changing how something works or looks, show the design:

- **User flow** — UI changes
- **System diagram** — architecture changes
- **Data flow** — pipeline changes
- **Before/after** — any change with tradeoffs

Show full context, not just the new piece. The diagram is the spec.
