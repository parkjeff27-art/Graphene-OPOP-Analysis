# OPOP Bi-exponential Fitting (TTM Model)

Automated gate-voltage-dependent fitting of OPOP transient reflectivity data using the Two-Temperature Model (TTM) bi-exponential function with RMSE quality analysis.

---

## Code

### `BasicFittingRMSEAnalysis.m`

A single-file MATLAB function that performs the complete fitting pipeline:

1. **Data Loading**: Reads time-delay vs ΔR data from Excel for 7 gate voltages (-15V to +20V)
2. **Auto-detection**: Automatically classifies signal as `graphene` (positive peak) or `graphene_on_au` (negative peak)
3. **Normalization**: Baseline subtraction + peak normalization
4. **TTM Bi-exponential Fitting**:
ΔR = A_e · (1 - exp(-t/τ_e)) · exp(-t/τ) + A_l · (1 - exp(-t/τ)) · exp(-t/τ_l)
   - First term: electron subsystem (fast rise τ_e, decay τ)
   - Second term: lattice subsystem (rise τ, slow decay τ_l)
5. **Multi-threshold optimization**: Tests multiple threshold values to estimate initial τ, selects best RMSE
6. **RMSE Quality Analysis**: Grades each fit (Excellent/Good/Fair/Poor)
7. **Output**: Results table saved to Excel + visualization plots

### Fitting Parameters

| Parameter | Description | Bounds |
|-----------|-------------|--------|
| A_e | Electron amplitude | [-3, 3] |
| A_l | Lattice amplitude | [-1, 3] |
| τ_e | Electron thermalization time | [0.01, 0.5] ps |
| **τ** | **Electron-phonon relaxation time** | **[0.05, 3.0] ps** |
| τ_l | Lattice cooling time | [1, 10] ps |
| y0 | Baseline offset | [-0.2, 0.2] |
| x0 | Time zero | [1.4, 2.6] ps |

The primary output is **τ (= τ₁ in the paper)**, which represents the hot carrier relaxation time modulated by gate voltage.

---

## Raw Data

| File | Description |
|------|-------------|
| `Fittinginputdata.xlsx` | OPOP transient reflectivity (ΔR) vs time delay for 7 gate voltages |
| `OPOP_ML_rawdata.xlsx` | Additional OPOP measurement raw data |

### Data Format (Fittinginputdata.xlsx)

| Column | Content |
|--------|---------|
| 1 | Time delay (seconds, converted to ps in code) |
| 2–8 | ΔR signal at gate voltages: -15V, -6V, -1V, 4V(CNP), 9V, 14V, 20V |

---

## Usage
```matlab
% Simply run in MATLAB:
BasicFittingRMSEAnalysis()

% Requires: Fittinginputdata.xlsx in the same directory
% Output: Working_FittingResults_with_RMSE.xlsx
```

---

## Output Visualization

The code generates two figures:
1. **Fitting Plot**: All gate voltages with data points + fitted curves, showing τ and RMSE per voltage
2. **Analysis Dashboard**:
   - Left panel: τ vs Vg with RMSE error bars
   - Right panel: RMSE bar chart with quality threshold lines

---

## RMSE Quality Thresholds

| Grade | RMSE Range | Interpretation |
|-------|-----------|----------------|
| Excellent | < 0.01 | Publication-quality fit |
| Good | 0.01 – 0.05 | Reliable for analysis |
| Fair | 0.05 – 0.10 | Acceptable with caution |
| Poor | ≥ 0.10 | Needs improvement |
