# Graphene-OPOP-Analysis

Ultrafast carrier dynamics analysis in single-layer graphene (SLG) and SLG-on-Au heterostructures under gate voltage modulation, using the femtosecond Optical-Pump Optical-Probe (OPOP) technique.

---

## Research Overview

This repository contains analysis codes and raw data for investigating how gate voltage modulates the photo-excited carrier relaxation in graphene-metal systems.

### Key Finding

SLG and SLG-on-Au exhibit **opposite** gate-voltage dependences of relaxation time:

| System | τ₁ vs Vg Shape | Mechanism |
|--------|---------------|-----------|
| **SLG** (pristine graphene) | **V-shaped** (minimum at CNP) | State filling + electron-phonon coupling modulation |
| **SLG-on-Au** | **Λ-shaped** (maximum at CNP) | Interfacial charge transfer efficiency across SLG–Au interface |

The Λ-shaped relaxation time in SLG-on-Au mirrors the gate-dependent contact resistance, providing direct optical evidence that contact resistance is governed by interfacial charge/energy transfer efficiency.

### Quantitative Highlights

- At **CNP (Vg = 0V)**: τ₁ is comparable for both SLG and SLG-on-Au (~0.5–0.7 ps)
- At **±15V**: τ₁ ≈ 1.05 ps (SLG) vs 0.3 ps (SLG-on-Au) → **~300% more efficient** interfacial transfer
- The relaxation time trend correlates with specific contact resistivity (ρc)

---

## Repository Structure
Graphene-OPOP-Analysis/
├── README.md                          ← Project overview (this file)
├── fitting/
│   ├── README.md                      ← Fitting code documentation
│   ├── BasicFittingRMSEAnalysis.m     ← TTM bi-exponential fitting + RMSE analysis
│   ├── Fittinginputdata.xlsx          ← OPOP raw data (7 gate voltages)
│   └── OPOP_ML_rawdata.xlsx           ← Additional OPOP measurement data
└── (more categories to be added)

---

## Experimental Setup

- **Laser**: Ti:Sapphire, 60 fs pulses, 800 nm, 80 MHz repetition rate
- **Pump power**: 0.6 mW (~76 μJ/cm² absorbed fluence)
- **Spot size**: ~2 μm (20× objective, normal incidence)
- **Detection**: Lock-in amplifier at ~1 kHz modulation
- **Sample**: CVD-grown SLG on Au/Ti (45/5 nm) electrodes, SiO₂/Si back gate
- **Gate voltage range**: -15 V to +20 V

---

## Requirements

- MATLAB (R2016b or later)
- Optimization Toolbox (`lsqcurvefit`)

---

## Author

**Junsu Park (박준수)**
Department of Physics and Photon Science, GIST (Gwangju Institute of Science and Technology)

- GitHub: [@parkjeff27-art](https://github.com/parkjeff27-art)
