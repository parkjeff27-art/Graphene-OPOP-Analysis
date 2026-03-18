\# Graphene-OPOP-Analysis



> \*\*Associated Paper\*\*: Gate-Tuned Hot Carrier Transfer in Graphene–Au Heterostructures — \*Applied Physics Letters\* (submitted)



Ultrafast carrier dynamics analysis in single-layer graphene (SLG) and SLG-on-Au heterostructures under gate voltage modulation, using the femtosecond Optical-Pump Optical-Probe (OPOP) technique.



---



\## Research Overview



This repository contains analysis codes and raw data for investigating how gate voltage modulates the photo-excited carrier relaxation in graphene-metal systems. The key finding is that SLG and SLG-on-Au exhibit \*\*opposite\*\* gate-voltage dependences of relaxation time:



| System | τ₁ vs Vg Shape | Mechanism |

|--------|---------------|-----------|

| \*\*SLG\*\* (pristine graphene) | \*\*V-shaped\*\* (minimum at CNP) | State filling + electron-phonon coupling modulation |

| \*\*SLG-on-Au\*\* | \*\*Λ-shaped\*\* (maximum at CNP) | Interfacial charge transfer efficiency across SLG–Au interface |



The Λ-shaped relaxation time in SLG-on-Au mirrors the gate-dependent contact resistance, providing direct optical evidence that contact resistance is governed by interfacial charge/energy transfer efficiency.



---



\## Repository Structure

Graphene-OPOP-Analysis/

├── README.md                 ← This file (project overview)

├── fitting/

│   ├── README.md             ← Fitting code documentation

│   ├── BasicFittingRMSEAnalysis.m

│   ├── Fittinginputdata.xlsx

│   └── OPOP\_ML\_rawdata.xlsx



---



\## Experimental Setup



\- \*\*Laser\*\*: Ti:Sapphire, 60 fs pulses, 800 nm, 80 MHz repetition rate

\- \*\*Pump power\*\*: 0.6 mW (~76 μJ/cm² absorbed fluence)

\- \*\*Spot size\*\*: ~2 μm (20× objective, normal incidence)

\- \*\*Detection\*\*: Lock-in amplifier at ~1 kHz modulation

\- \*\*Sample\*\*: CVD-grown SLG on Au/Ti (45/5 nm) electrodes, SiO₂/Si back gate

\- \*\*Gate voltage range\*\*: -15 V to +20 V



---



\## Key Results



\- At \*\*CNP (Vg = 0V)\*\*: τ₁ is comparable for both SLG and SLG-on-Au (~0.5–0.7 ps)

\- At \*\*±15V\*\*: τ₁ ≈ 1.05 ps (SLG) vs 0.3 ps (SLG-on-Au) → \*\*~300% more efficient\*\* interfacial transfer

\- The relaxation time trend correlates with specific contact resistivity (ρc), linking ultrafast dynamics to DC transport properties



---



\## Requirements



\- MATLAB (R2016b or later)

\- Optimization Toolbox (`lsqcurvefit`)



---



\## Author



\*\*Junsu Park (박준수)\*\*

Department of Physics and Photon Science, GIST (Gwangju Institute of Science and Technology)



\- GitHub: \[@parkjeff27-art](https://github.com/parkjeff27-art)

\- Related: \[Contact-Resistance-MC-Simulation](https://github.com/parkjeff27-



