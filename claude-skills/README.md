# Claude skills: dependency layers

Each skill directory installs to `~/.claude/skills/<name>/`. A skill may refer
to a skill in a lower layer only. A reference to a peer or a higher layer is a
defect.

| Layer | Skills | May refer to |
|---|---|---|
| 1 | `spawn-haiku-idle-tidy`, `spawn-dependabot-rebase-merge` | `spawn-haiku-autonomous-onepr-merge`; `spawn-haiku-idle-tidy` also `code-design-bias`; `spawn-dependabot-rebase-merge` also `jj-merge-pr` |
| 2 | `spawn-haiku-autonomous-onepr-merge` | `spawn-haiku-onecommit-pr`, `spawn-haiku-amend-commit`, `jj-merge-pr`, `code-design-bias`, `autonomous-loop-discipline` |
| 3 | `spawn-haiku-onecommit-pr`, `spawn-haiku-onecommit-nopr`, `spawn-haiku-amend-commit` | `haiku-worker-run`, `jj-worker-workspace` |
| 4 | `haiku-worker-run` | `jj-worker-workspace`, `jj-sweep-wip-bookmarks` |
| 5 | `jj-worker-workspace`, `jj-sweep-wip-bookmarks`, `jj-merge-pr`, `code-design-bias`, `autonomous-loop-discipline` | none |

`interview-me` and `technical-writing` stand alone and refer to no other skill.
`spawn-haiku-idle-tidy` reaches `jj-merge-pr` only through
`spawn-haiku-autonomous-onepr-merge`.

## Audit

List every skill-to-skill reference, then compare the output with the table:

```bash
cd claude-skills
for a in */; do a=${a%/}; for b in */; do b=${b%/}; [ "$a" = "$b" ] && continue
  grep -q -- "$b" "$a"/* && echo "$a -> $b"; done; done
```
