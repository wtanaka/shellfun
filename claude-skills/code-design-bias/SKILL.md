---
name: code-design-bias
description: Design principles for new code: pure functions, total functions, one definition for repeated logic, and illegal states made unrepresentable. Use when briefing a worker on a coding task, reviewing a diff, or writing code where logic, I/O and types need to be shaped well.
---

# Design bias: pure, total, one definition, and illegal states unrepresentable

Apply these principles when writing code, when briefing a worker, and when
reviewing a diff. Weaker models drift toward imperative code with checks
sprinkled in, so state the principles outright in every brief and review every
diff against the principles. Logic sitting in an adapter, a partial function,
or a state that the types allow but the program must not reach is a defect to
send back, not a style nit.

- **Maximally pure.** Decisions, scheduling, parsing and formatting are pure
  functions or pure types: no I/O, no globals, no clocks, no escape hatches
  around the type system. Anything that talks to the outside world (foreign
  calls, platform APIs, files, network, worker processes, ports) is a thin
  adapter. The adapter turns the outside into plain values, calls the pure
  code, and turns the answer back. Inject the sources (a function or iterator)
  so tests use fakes and need no external tools.
- **Complete (total) functions.** A total function is defined for every input
  of the declared type: no panics, no thrown errors for expected cases, no
  sentinel values (`-1`, `""`, `null` meaning "none"). Return an option or a
  result that states what happened.
- **Illegal states unrepresentable by construction, when possible.** Prefer a
  type that cannot be built wrong over an assert that notices the error later.
  Concretely:
  - a flag plus optional fields becomes a sum type (an enum or tagged union);
  - a raw number or string with a runtime check becomes a newtype, a branded
    type or a validated constructor;
  - a sentinel value becomes an option or a result;
  - two fields that only make sense together become one value.
- **One definition (DRY).** Collapse two or more copies of the same logic,
  constant, pattern, type or tag format that must change together into one
  definition. A helper needs two or more real call sites; a parameterized
  abstraction needs three. Do not unify code that is similar by coincidence or
  that differs on purpose.
- **Test the pure core thoroughly,** including edge cases and empty inputs.
  Test the adapter only for the translation the adapter uniquely does.
- When the surrounding code is not shaped for these principles, say so (in the
  PR body, for a worker) instead of bending the design. Then decide whether to
  refactor first, as a separate earlier change, or to accept the shape.
