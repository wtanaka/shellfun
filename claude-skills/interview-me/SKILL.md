---
name: interview-me
description: Interview the user about open decisions, one question at a time, in the conversation (never with the question tool). Each question leads with a recommendation and is explained as if the user had no context. Use when the user says "interview me", "ask me what you need", "clarify the backlog with me", or when several decisions block work.
---

# Interview me: one question per message, in the chat, from zero context

Ask in the conversation, never with the AskUserQuestion tool (the user skips it and answers in chat).

## Rules

1. **One question per message.** If several decisions are open, queue them privately and ask the one that unblocks the most work first. When more than one remains, end with "N more after this".
2. **Recommendation first.** The first line names the decision and the recommended option with the one deciding reason: "Recommend B: <reason>."
3. **Explain from zero.** At most 3 sentences: what the thing is, what changes now, why a decision is needed now. Plain words, no unglossed jargon. Issue numbers and code names may follow in parentheses.
4. **Match the size to the decision.** Two options with an obvious default get 3 lines and no matrix: the recommendation, the alternative in one sentence, and "Reply 'matrix' for the full comparison with examples." On "matrix", send the full format below, matrix and examples. Anything with 3 or more options, or real risk, gets the full format at once.
5. **Full format: a comparison matrix, then examples.** Matrix: options as columns, the criteria that differ as rows (for example what happens, cost, risk, what it unlocks, how easily it is undone), recommended option marked in the header. Examples: one short story per option, written as what the user would see or do, with real (invented) names and numbers. A story shows the option in use; it does not repeat the matrix cells.
6. **Make answering cheap.** End with the exact reply wanted ("Reply A, B or C, or tell me what to change"). Accept a one-word answer. Say what happens with no reply (usually: the item stays held, nothing is lost).
7. **Never block, never over-ask.** Keep non-conflicting work going while the question is pending. Make safe decisions with a sensible default, say so, and move on.
8. **After the answer:** confirm in one sentence, act on it (update issues, write a memory if it is a standing preference), then ask the next question in a new message.

## Full-format shape

```
## <the decision in plain words>

**Recommend <option>: <reason>.**

**What this is.** <up to 3 sentences>

| | A. <name> | B. <name> (recommended) | C. <name> |
|---|---|---|---|
| ... | | | |

**Examples.** <one short story per option>

Reply A, B or C (or tell me what to change). <N more after this.>
```
