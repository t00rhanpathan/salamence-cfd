# Salamence & Mega Salamence aerodynamics: preprint spec

Repo copy of the project spec, trimmed for agents. The full, illustrated version lives in the Claude Doc "Salamence & Mega Salamence Aerodynamics: Preprint Spec". If the two disagree, ask the user.

## 1. Goal and scope

Compare the steady gliding aerodynamics of Salamence (separate wings) and Mega Salamence (fused crescent wing) with original parametric geometry and a laptop-only open-source toolchain. Question: does the crescent wing trade cruise efficiency for high-angle-of-attack vortex lift? Out of scope: flapping, aeroelasticity, transition modelling.

Fidelity stance: VSPAERO gives the main polars; 6 RANS cases + 2 mesh-study cases check them and give flow-field figures. Assumed-geometry uncertainty (span ±25%) dwarfs solver error, so nothing beyond steady RANS is run.

## 2. Repo layout (one folder per role's output)

```
CONTEXT.md  assumptions.yaml  refs.bib  Snakefile
geometry/      make_geometry.py, salamence.vsp3, mega.vsp3, *.stl, renders        (Geometry)
lowfi/         vspaero sweep scripts, polars_<form>_<span>.csv                      (Low-fi aero)
cfd/validation/naca0012/                                                            (Validation)
cfd/cases/<form>_a<deg>[_<mesh>]/, cfd/run_all.sh, cfd/summarize.py               (CFD setup)
results/       cfd_summary.json, key_numbers.tex
verification/  gci.py, verification.md                                             (Verification)
figures/       style.py, make_figures.py, fig_*.pdf|png                            (Figures)
paper/         main.tex, sections/*.tex                                            (Writer)
briefs/        one brief per subagent run                                          (Orchestrator)
```

## 3. Geometry

- One script, `geometry/make_geometry.py`, reads `assumptions.yaml`, writes both `.vsp3` files and watertight STLs (OpenVSP Python API).
- Torso/neck/tail: OpenVSP Fuselage stack, elliptical sections, about 8 stations. Head: short body of revolution, no horns at first. Legs tucked into a fairing.
- Salamence: two tapered wings, ~15° LE sweep, rooted high. Mega: one continuous crescent, ~45° LE sweep, curved TE.
- Airfoil NACA 4412 throughout, rigid (stated assumption).
- Gate: both STLs watertight (trimesh), wing reference area within 1% of yaml, one render per form looks like the creature. Stop iterating on likeness there.
- Never use ripped game models or traced artwork. Paper carries a trademark disclaimer.

Derived values for the yaml baseline: aspect ratio 5.5 / 3.6; wing loading 314 / 307 N/m²; cruise 32 m/s at CL 0.5; min speed ~20 / 19 m/s at CL 1.3; Re (mean chord) ~1.5e6 / 2.0e6.

## 4. Meshing (OpenFOAM blockMesh + snappyHexMesh)

- Half model, symmetry plane. Domain: 10 spans upstream, 20 downstream, 10 above/below/side.
- Surface refinement levels 5–6 wings, 4–5 body, +1 on LE/TE feature edges. Wake box to 1 span downstream at level 3; for Mega a cone above the wing at level 4 for the LE vortex.
- 5–8 prism layers, growth 1.2, first cell for y+ 30–100 (~0.6 mm estimate).
- Gates: checkMesh passes, max non-orthogonality < 65, wing layer coverage > 90% (tips may be 80%).
- Meshes (half model): coarse 0.40 m background ≈1.2 M cells; medium 0.30 m ≈2.7 M (all production); fine 0.23 m ≈6 M (mesh study only).

## 5. Solvers

| Level | Method | Use |
|---|---|---|
| 0 | Lifting line, Polhamus suction analogy, allometry (Python) | Sanity bounds, vortex-lift estimate |
| 1 | VSPAERO VLM + OpenVSP parasite drag build-up | Main polars: alpha −4..20 step 2, both forms, span ×0.75/1.0/1.25 = 78 points |
| 2 | OpenFOAM simpleFoam, k-omega SST, medium mesh | 2 forms × alpha 4/10/18 = 6 runs |
| 3 | URANS/DES/flapping | Not run (future work) |

OpenFOAM template: steady incompressible, ρ 1.225, ν 1.5e-5, U 32 m/s; SST with TI 0.1%, viscosity ratio 10; nutk/kqR/omega wall functions; freestreamVelocity/freestreamPressure far field, symmetry mid-plane, noSlip body; bounded Gauss linearUpwind for U, limited linear for k/omega, GAMG for p; forceCoeffs with Aref = half wing area, lRef = MAC, CofR at quarter MAC, lift/drag dirs rotated with freestream. Alpha changes by rotating the freestream, so one mesh per form. decomposePar (scotch) + mpirun on all physical cores. Stop at 2000 iterations or CL/CD change < 0.5% over 200. Non-converging 18° cases: report the average of the last 500 iterations; do not escalate to unsteady.

## 6. Validation and verification

1. NACA 0012, Re 6e6 (NASA Turbulence Modeling Resource), same settings: lift within 5%, drag within 10% at 0/10/15°. Runs before any creature case.
2. GCI (Celik et al. 2008, J. Fluids Eng. 130, 078001) on Mega at 10°, coarse/medium/fine: GCI_medium < 5% CL, < 10% CD. One retry with +1 wing level, else report as uncertainty.
3. Cross-check Salamence 4°: VSPAERO vs OpenFOAM lift within ~10%. Mismatch → check Aref and CofR first.
4. Residuals down 3 orders; CL/CD steady 0.5% over last 200 iterations.
5. Wing-averaged y+ 30–100 on the medium mesh.

## 7. Figures (all regenerated by `make figures` from data)

1 Three-view of both geometries · 2 CL vs alpha (VSPAERO lines + OpenFOAM points) · 3 Drag polar and L/D vs CL · 4 Span sensitivity (max L/D, min sink vs span) · 5 Surface Cp at 10° · 6 Mega LE vortex (Q-criterion) vs Salamence separation at 18° · 7 Spanwise lift vs elliptical · 8 Glide hodograph (sink vs airspeed).

`figures/style.py` sets fonts, 3.4 in / 7 in widths, one colour per form. Vector PDF for plots; ParaView PNG at 300 dpi via `pvbatch --force-offscreen-rendering`. Text numbers go to `results/key_numbers.tex` as macros.

## 8. Manuscript

~8 pages, article class + natbib, latexmk. Sections: Abstract (150 words) · Introduction 0.75 p · Geometry and assumptions 1 p · Methods 1.25 p · V&V 0.75 p · Results 2 p · Discussion 1 p · Conclusion + data/code availability + trademark disclaimer. Every number from `key_numbers.tex`; every external claim cited and verified; straight technical tone.

## 9. Venues

Zenodo first (DOI on day one, CC BY 4.0, GitHub release integration). Then arXiv physics.pop-ph with cross-list physics.flu-dyn (endorsement likely needed; moderation not guaranteed). Fallbacks: engrXiv, OSF Preprints. Title leads with the aerodynamics question, not a joke.

## 10. Subagent blueprint

Phases (each waits for the previous gate; roles in one phase run in parallel, except Paper):

| Phase | Role | Model | Produces | Gate | Turn cap |
|---|---|---|---|---|---|
| — | Orchestrator (main session) | Fable | briefs/, gate decisions | each phase gate | — |
| 1 | Literature | Sonnet, standard web search | refs.bib (~15, DOIs opened), assumptions_notes.md | every assumed value justified | 25 |
| 1 | Validation | Sonnet | cfd/validation/naca0012, validation.csv | §6.1 passes | 25 |
| 2 | Geometry | Sonnet | geometry/* | §3 gate | 30 |
| 2 | Low-fi aero | Haiku (Sonnet after 2 failures) | lowfi/polars_*.csv | 78 points, no NaN | 15 |
| 3 | CFD setup | Sonnet | cfd/cases/*, run_all.sh, summarize.py | checkMesh passes, runs launched in background | 30 |
| 3 | Runs | no LLM | results/cfd_summary.json | all 8 runs finished | — |
| 4 | Verification | Sonnet | verification/* | §6.2–6.5 reported | 15 |
| 4 | Figures | Sonnet | figures/*, results/key_numbers.tex | 8 figures render | 25 |
| 5 | Writer (draft, then revise via message) | Opus | paper/* | compiles, ≤ 9 pages, no hand-typed numbers | 20/pass |
| 5 | Reviewer (fresh context, PDF + verification.md only) | Opus | 1-page ranked referee report | delivered | 8 |
| 5 | Packager | Haiku | submission tarball with .bbl, Zenodo + arXiv metadata | compiles in clean dir | 10 |

Brief template (≤ 300 words):

```
Role: <one line>
Read first: CONTEXT.md, then only these files: <paths>
Task: <3-6 numbered steps>
Outputs: <exact paths and formats>
Done when: <the gate, as a checkable test>
Limits: max <N> tool turns; after 2 failed attempts at one step, stop and report.
Return: under 150 words: what was made, its paths, any deviation. Do not paste file contents.
```

Token rules: files are the interface; shared CONTEXT.md prefix for caching; no agent reads logs; no polling; fix via SendMessage to the same agent; cheapest tier that passes the gate; standard web search only, one review round; scripts over agent labour.

## 11. Budget and stop rules

Compute ≈ 15 h on an 8-core laptop (two nights), no cloud. Stop rules: no unsteady/DES/flapping/transition; no mesh > ~6 M cells; no CFD cases beyond the 8 listed (new questions go to VSPAERO first); one review round, one revision, then submit.
