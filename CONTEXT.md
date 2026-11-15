# CONTEXT (every subagent reads this first; keep it under one page)

**Study.** Steady gliding aerodynamics of Salamence (two separate bat-like wings) vs Mega Salamence (one fused crescent wing), for an open preprint. Question: does the crescent wing trade cruise efficiency (L/D, span efficiency) for high-angle-of-attack vortex lift?

**Rules that apply to every role.**
- Fictional creature, original geometry only. Never use ripped game models or traced official art.
- All inputs come from `assumptions.yaml`. Never hand-type a number into code or prose; read it or write it to `results/key_numbers.tex`.
- Open-source tools only: OpenVSP/VSPAERO, OpenFOAM (simpleFoam, k-omega SST), ParaView pvpython, Python (.venv), LaTeX.
- Everything runs inside WSL2 Ubuntu with `.venv/bin/python` (Python 3.12). Source OpenFOAM's bashrc before any OpenFOAM command.
- Fidelity stops at steady RANS: 6 production cases + 2 mesh-study cases. No unsteady, DES, flapping or transition models.
- Never read raw solver logs; read `results/cfd_summary.json` produced by `cfd/summarize.py`.
- Long runs go to the background with nohup; end your turn instead of polling.

**Output contract.** Write only inside your role's folder (see SPEC.md "Repo layout"). Return under 150 words: what you made, its paths, any deviation from the brief. Do not paste file contents.

**Failure rule.** After 2 failed attempts at one step, stop and report what failed and what you tried.

Full spec: `SPEC.md` (read only the section your brief names).
