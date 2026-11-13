---
name: technical-writing
description: Style rules for technical documents (design docs, plans, specs, ADRs, READMEs, issue and PR write-ups). Use when writing or editing a design doc, plan, spec, ADR, README, or any long-form technical prose.
---

# Technical writing style

These rules govern documents, not chat replies. When editing an existing document, bring the touched sections into line and leave the rest alone unless asked.

## Core rules (every document)

1. **No pronouns.** Do not write "it", "its", "they", "them", "their", "this", "that", "these", "those", "we", "our", "you", "he", "she" or "which" in place of a noun. Repeat the noun: "the parser validates the request", not "it validates this". First person is forbidden: "the parser assumes UTF-8 input", not "we assume UTF-8 input". Refer to the document itself by title or identifier ("ADR-7 assumes ..."), never "this document" or "the design". Rule 5's "we think" is the one fixed exception.
2. **One word per concept.** Pick a term and use exactly that term everywhere. Never vary a noun for style ("user", then "account", then "customer" for one person). Never reuse one word for two concepts. When a term changes during editing, change every occurrence.
3. **Standard terminology over coined jargon.** Search the relevant standard, specification, textbook or API for the established term before inventing one. Example: a URL has a scheme, authority, path, query and fragment (RFC 3986); HTTP has "request", "response", "status code" and "header field" (RFC 9110). Cite the standard (name and section) at the first use. When no standard term exists, define the invented term and say that the term is invented.
4. **Active voice.** The subject performs the action: "the server emits `RequestCompleted`". Passive voice is allowed only when the actor is unknown or irrelevant and a rewrite would be longer.
5. **Numbers over adjectives, with units.** Write "the service handles 200 requests per second", not "handles requests fast". Delete "fast", "slow", "large", "small", "many", "few", "significant", "about" and "roughly" unless a number follows. When a number is unknown, write "we think" plus the estimate and what would settle it: "we think the batch job takes 90 seconds per 1,000 records; a measurement on production data would confirm". Mark each number as specified (a requirement), measured (with date and method), or "we think".
6. **Comparison matrices, not pros and cons.** One table: options as columns, criteria as rows, a number or short fact in each cell. Mark the recommended option in the header. Put the recommendation and its single deciding reason in one sentence under the table.
7. **Alternatives considered.** Every decision has a section named "Alternatives considered": one row per rejected option with the reason for rejection and the condition that would reopen the question. A decision without a recorded alternative is incomplete.

## Design docs and ADRs (also apply)

8. **Lead with the decision or the result.** The first paragraph states what the document decides or proposes, plus the status (draft, proposed, accepted, superseded) and date.
9. **Scope and non-goals.** A short list of what the document covers and excludes.
10. **Terms section.** For documents longer than one page: a table of term, definition and source (standard name or "invented here").
11. **Units in names and prose.** Identifiers carry units (`TIMEOUT_SECONDS`, `maxPayloadBytes`). Prose repeats the unit with every number. Use one spelling convention (American English unless the project says otherwise).
12. **Fixed requirement words.** "Must" is required, "should" is recommended, "may" is optional (RFC 2119). Use no other modal verb in a requirement.
13. **Every claim has a source.** Link or name the file, standard, measurement or conversation. Write file references as `path/to/file.ts`, with a line number when stable.
14. **Separate fact, estimate and opinion.** Facts carry a source, estimates carry "we think", opinions live in a Recommendation section.
15. **Open questions are a list with an owner.** Each item names who decides and what blocks the decision.
16. **Worked examples.** Each rule or formula gets one example with real numbers and the arithmetic shown.
17. **Short sentences.** One idea per sentence, fewer than 25 words. Put the longest content in tables.
18. **Stable headings.** Sentence-case headings. Search for links to the old anchor before renaming a heading.
19. **No filler.** Delete "simply", "just", "obviously", "easily", "robust", "seamless" and similar words.
20. **No inline changelog.** Revision control records the history.

## Before saving

Search the document for pronouns, passive voice, adjectives without numbers, and "Pros" or "Cons" headings. Fix every hit.
