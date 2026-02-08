Template rules: Codex placeholder fill prompt

Use this prompt after copying this repo into a new project:

You are updating a copied rules template. Replace every placeholder of the form `<CODEX:<tag>: ...>` with project-specific paths, filenames, commands, and examples from this repository.
- Keep each rule’s intent; only substitute the missing specifics.
- If a placeholder asks for examples, give at least one concrete example.
- If info is missing, add TODOs with the best guess and ask a short question at the end.
After filling, verify there are no remaining `<CODEX:<tag>: ...>` placeholders.

Tag legend:
- path: filesystem paths and file examples
- cmd: commands or scripts
- mock: mocks or fixtures locations
- style: UI or palette helpers
- module: Swift module names for imports
