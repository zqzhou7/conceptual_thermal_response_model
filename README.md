# Thermal Stress Response Visualization Model

This R script generates conceptual plots to visualize how marine organisms might respond to increasing **thermal stress variability**, accounting for potential **skewness in response**, **threshold tipping points**, and **increasing variability (funnel effect)** in outcomes.

---

## 🧠 Conceptual Overview

The purpose of this script is to explore idealized, generalized **response profiles** of organisms under environmental stress. It simulates three key types of response dynamics commonly observed in nature and ecology, especially under climate-driven thermal pressures.

> ⚠️ **Note:** This is a **simplified conceptual model** meant for visualization and hypothesis generation. It is not calibrated to empirical data, and the metrics used are illustrative.

---

## 📈 Axis Definitions

### X-axis: **Thermal Stress Variability**

- Represents a **summary index** of temperature-related stress.
- Captures temporal variability in:
  - **Duration** of thermal events
  - **Frequency** of occurrence
  - **Intensity** of extremes
- Reflects how unstable or stressful thermal conditions are over time.

**Important:** This is a **conceptual axis**. Exact definitions and ecological calculations of this index (e.g., integrating degree-days, frequency thresholds, variance metrics) are open for further discussion and refinement.

---

### Y-axis: **Organism Response Index**

- Represents a generalized **physiological or behavioral response**.
- Can reflect:
  - **Metabolic activity** (e.g., respiration rate)
  - **Energy intake/output** (e.g., food consumption)
  - **Performance or fitness proxies**

---

## 🔍 Interpreting the Three Response Profiles

Each of the three panels in the output figure illustrates a different ecological response pattern that could emerge as thermal stress increases:

---

### 1. **Symmetric Response (Normal)**

**Description:**  
- The response curve follows a **smooth, bell-shaped distribution**.
- Organism performance initially improves with moderate variability but declines as conditions become too erratic.
- Reflects **tolerance within limits**, without a strong tipping point.

**Interpretation:**  
Species or traits that are resilient to moderate variability but show symmetrical performance decline beyond optimal conditions.

---

### 2. **Left-Skewed Response (Threshold Collapse)**

**Description:**  
- Performance is **high under stable conditions**, but drops **abruptly after a threshold**.
- Strong **left skew**: a sharp crash occurs beyond a certain point of variability.
- High sensitivity to change, indicating **nonlinear collapse or failure** past the tipping point.

**Interpretation:**  
Species or populations that are vulnerable to sudden thermal breakdowns—e.g., when key physiological limits are exceeded (e.g., enzyme denaturation, starvation thresholds).

---

### 3. **Right-Skewed Response (Filtered Survivors)**

**Description:**  
- Performance is **low under moderate stress**, but improves at higher variability.
- Indicates a **right-skewed distribution** — possibly due to **selection or filtering** where only tolerant individuals persist.
- Suggests that the population has **adapted** or shifted toward higher tolerance over time.

**Interpretation:**  
Scenarios where survivors represent a **subset of tolerant individuals**, and low-performance individuals have been eliminated by prior stress exposure or mortality.

---

## 🔧 Parameter Tuning

At the top of the script, key parameters are grouped for easy modification:

- `n`: Number of data points
- `threshold_point`: Point on the x-axis where the threshold/tipping occurs
- `skew_value`, `center_shift`, `drop`: Control the response shape for each scenario
- `custom_colors`: Set the visual color scheme

---

## 📊 Output

The script produces a figure titled:

**`3phases_threshold_funnel_skew.png`**

Which includes:

- Data points representing individual organism responses
- Pre- and post-threshold trend lines
- 95% quantile ribbons
- Visual shading to indicate the threshold zone

---

## 🛠 Requirements

Install the following R packages if not already available:

```r
install.packages(c("ggplot2", "sn", "gridExtra", "viridis", "quantreg", "dplyr", "cowplot"))
