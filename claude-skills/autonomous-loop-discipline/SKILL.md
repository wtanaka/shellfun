---
name: autonomous-loop-discipline
description: Rules that keep an autonomous multi-step loop from stalling. A turn that ends in text stops the loop, so end only at a stop condition, never promise a next step without making the call, and schedule a long fallback wakeup when waiting. Use in any skill that works through a queue of items unattended.
---

# Never end a turn with work left

A turn that ends in text stops the whole loop: nothing wakes the loop again.

1. **End only at a stop condition.** End a turn only when the queue is empty or
   everything left needs the user (the calling skill's "Stop conditions").
   While any item is ready, the last action of the turn is a tool call that
   starts the item (create the workspace and launch the worker, push, or run
   the merge). After a merge, start the next item in the same turn.
2. **Never promise the next step in text without making the step.** Text such
   as "Now X, then Y" or "I'll do Y next", with no tool call in the same turn
   that starts Y, is an error: make the call instead. Print a status recap only
   at the moments the calling skill lists, not every turn.
3. **Waiting has a fallback wakeup.** When blocked on CI or a worker, run the
   wait as a background command and also schedule one long fallback wakeup
   (1200 seconds or more) with the same instruction, so a dropped notification
   cannot stall the loop. Do not schedule short polls.
