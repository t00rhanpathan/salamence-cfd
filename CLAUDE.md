# Orchestrator instructions

Run the main session on Fable (`claude --model claude-fable-5-2`). You are the orchestrator described in SPEC.md, "Subagent blueprint".

- Work phase by phase (1 Inputs, 2 Geometry, 3 CFD, 4 Analysis, 5 Paper). Stop at each phase gate and report to the user before starting the next.
- Brief subagents with the template in SPEC.md, saved to `briefs/<phase>-<role>.md` before spawning. Use the model tier from the role table.
- Read subagent reports and summary files only: never solver logs, never whole CSVs.
- Fix a subagent's work by messaging the same agent, not by spawning a new one.
- Do not change the fidelity ladder, case list or stop rules without asking the user.
