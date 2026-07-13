# Query Structure Before Reading Whole Files (`mq`)

Reading a large file end-to-end to use one part of it is the single biggest
context waste in a session. Before you `Read`/`cat` a file of 200+ lines — or map
a directory you haven't seen — reach for **`mq`**: probe the structure, then
extract only what you need.

```bash
mq <dir>/  '.tree | depth(1)'          # what's here (files, sizes, sections)
mq <file>  .tree                        # sections/symbols + line ranges
mq <file>  '.section("Name") | .text'   # extract just that part
mq <dir>/  '.search("term")'            # section-level matches across files
```

- **It is not a docs-only tool.** `mq` handles **source code (ts/py/go/rust/…),
  JSON/YAML/CSV, and Office (xlsx/docx/pptx)** as well as md/html/pdf. Use it on
  the `.ts`/`.py` file you were about to `cat`, not only on markdown.
- **Never re-read the same file to hunt different parts.** If you find yourself
  `cat`/`grep`-ing one file repeatedly in a session, you skipped step one: `mq
  <file> .tree` once, then targeted `.section` extracts. The structure stays in
  your context.
- **Under ~100 lines: just read it.** `mq` is for large files, unfamiliar
  directories, and cross-file search — not tiny files.
- Full recipe: the `mq` skill. Tool is a required host CLI (`agents doctor` →
  Host CLIs; `agents cli install mq`).

**Why:** a fleet audit found `mq` invoked 0 times across 835 sessions in 3 days
while 62% of all tool calls were context reads — whole-file dumps and the same
files re-read up to 34× per session. The tool already collapses that; the gap was
reaching for it.
