# Hospital Readmissions Analysis

An end-to-end data analysis project examining hospital readmission performance across the United States using CMS Hospital Readmissions Reduction Program (HRRP) data. The project includes a SQL data pipeline, regression modeling, and an interactive R Shiny dashboard.

---

## Project Overview

The Hospital Readmissions Reduction Program (HRRP) is a CMS initiative that reduces Medicare payments to hospitals with excess readmissions. This project analyzes FY2026 HRRP data to identify geographic patterns, condition-level differences, and hospital-level predictors of excess readmission ratios.

**Dataset:** 8,037 observations across 2,477 hospitals in all 50 states, covering six medical conditions (AMI, Heart Failure, Pneumonia, COPD, Hip/Knee Replacement, CABG).

**Data Source:** [Centers for Medicare and Medicaid Services — data.cms.gov](https://data.cms.gov/provider-data/dataset/9n3s-kdb3)

---

## Repository Structure

```
hospital-readmissions-analysis/
│
├── data/
│   ├── FY_2026_Hospital_Readmissions_Reduction_Program_Hospital.csv  # Raw CMS data
│   └── hospital_readmissions_clean.csv                                # Cleaned data (N/A removed)
│
├── sql/
│   └── hospital_readmissions_analysis.sql   # SQL queries for data exploration and cleaning
│
├── app.R                                    # Shiny dashboard (UI + Server)
├── global.R                                 # Data loading and library imports
├── setup_project.R                          # Package installation script
├── hospital_readmissions.Rproj              # RStudio project file
└── README.md
```

---

## Tools & Technologies

- **PostgreSQL** — database setup and data management
- **DBeaver** — SQL client for querying and exporting data
- **R / RStudio** — statistical analysis and modeling
- **Shiny / shinydashboard** — interactive dashboard
- **plotly** — interactive visualizations
- **tidyverse** — data manipulation

---

## SQL Analysis

Three analytical queries were written in PostgreSQL to explore the data before modeling:

1. **Average excess readmission ratio by state** — identified geographic variation in performance
2. **Average excess readmission ratio by condition** — compared performance across six medical conditions
3. **Worst performing hospitals** — ranked hospitals by average excess ratio across multiple conditions

---

## Shiny Dashboard

The interactive dashboard includes five tabs:

- **Overview** — summary statistics and top 20 worst performing hospitals
- **By State** — state-level bar chart and sortable summary table
- **By Condition** — condition comparison and state-condition heatmap
- **Regression Analysis** — linear regression model output, predicted vs actual plot, and coefficient plot
- **Findings & Conclusions** — written summary of key findings and limitations

---

## Key Findings

- Massachusetts, New Jersey, and Florida have the highest average excess readmission ratios nationally
- Hip and knee replacement procedures show the highest excess readmission ratios across all six conditions
- A linear regression model using discharge volume, number of conditions, and total readmissions explained approximately 33% of the variation in hospital performance (Adjusted R-squared = 0.33)
- Larger hospitals with higher discharge volumes tend to perform slightly better on readmission metrics

---

## How to Run

1. Clone the repository
2. Open `hospital_readmissions.Rproj` in RStudio
3. Run `setup_project.R` to install required packages
4. Run `global.R` to load the data
5. Run `app.R` to launch the Shiny dashboard

---

## Author

**Aaron Pongsugree**  
M.S. Biostatistics, George Mason University  
[GitHub](https://github.com/aaronpongsugree) | aaronpong21@gmail.com
