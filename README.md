# Medical Insurance Data Analysis | SQL Exploratory Data Analysis (EDA)

![SQL](https://img.shields.io/badge/Language-SQL-blue) ![Tool](https://img.shields.io/badge/Tool-MySQL%20Workbench-orange) ![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset Description](#dataset-description)
- [Project Objectives](#project-objectives)
- [Process Workflow](#process-workflow)
- [Key Analyses Performed](#key-analyses-performed)
- [Key Insights and Findings](#key-insights-and-findings)
- [Recommendations](#recommendations)
- [Tools Used](#tools-used)
- [How to Reproduce](#how-to-reproduce)
- [File Structure](#file-structure)
- [Conclusion](#conclusion)

---

## Project Overview

This project is an end-to-end **Exploratory Data Analysis (EDA)** conducted using SQL on a health insurance dataset containing records for **1,338 policyholders**. The goal is to uncover patterns and relationships across policyholder demographics, lifestyle factors (particularly smoking), BMI classifications, family structure, and regional distribution as they relate to medical charges.

The analysis is designed to help insurance providers move beyond surface-level pricing toward **data-driven, risk-informed decision making**. Every query was structured to answer a real business or actuarial question, and the findings are translated into actionable recommendations.

---

## Dataset Description

The dataset (`medical_insurance.csv`) contains **1,338 rows** and **7 columns**, representing individual insurance policyholders in the United States.

| Column | Data Type | Description |
|---|---|---|
| `age` | Integer | Age of the primary policyholder |
| `sex` | Text | Gender of the policyholder (male / female) |
| `bmi` | Float | Body Mass Index, an indicator of body fat based on height and weight |
| `children` | Integer | Number of dependents covered under the insurance plan |
| `smoker` | Text | Whether the policyholder is a smoker (yes / no) |
| `region` | Text | Residential region in the US (northeast, northwest, southeast, southwest) |
| `charges` | Float | Individual medical costs billed by the insurance provider (USD) |

**BMI Classification Reference:**

| BMI Range | Category |
|---|---|
| Below 18.5 | Underweight |
| 18.5 to 24.9 | Normal Weight |
| 25.0 to 29.9 | Overweight |
| 30.0 to 34.9 | Obese I |
| 35.0 to 39.9 | Obese II |
| 40.0 and above | Obese III |

---

## Project Objectives

This analysis was built around five core analytical areas:

1. **Demographic Profiling:** Understand the age, gender, regional, and BMI composition of the policyholder base.
2. **Charges and Cost Analysis:** Identify average, minimum, and maximum charges, and understand how costs vary across groups.
3. **Smoking Impact Assessment:** Quantify the financial and health-related difference between smokers and non-smokers.
4. **BMI and Health Risk Analysis:** Explore the relationship between BMI classification and medical charges.
5. **Family and Dependents Analysis:** Determine how the number of children influences medical costs.

---

## Process Workflow

The analysis followed a structured, repeatable workflow to preserve data integrity throughout.

**Step 1: Data Staging**
A staging table (`insurance_staging`) was created as a copy of the original dataset. All analysis was performed on the staging table, leaving the source data untouched.

**Step 2: Duplicate Detection and Removal**
Using `ROW_NUMBER()` with a `PARTITION BY` clause across all seven columns, duplicate records were identified. A second staging table (`insurance_staging1`) was created to include the `row_num` column, enabling easy deletion of duplicate rows.

**Step 3: Exploratory Analysis**
Twenty structured SQL queries were written across five analytical categories to answer specific business and actuarial questions. These covered demographics, costs, BMI, family structure, and combined multi-variable breakdowns.

**Step 4: Cleanup**
After analysis was complete, the `row_num` column was dropped from the staging table using `ALTER TABLE`, returning the dataset to its original structure.

---

## Key Analyses Performed

### Demographics and Distribution
- Average age of policyholders
- Gender distribution across the dataset
- Regional policyholder count
- Average BMI by gender
- Distribution of policyholders by number of children

### Charges and Cost Analysis
- Overall average, minimum, and maximum medical charges
- Average charges for smokers compared to non-smokers
- Average charges broken down by region
- Highest-cost region identification
- Average charges segmented by age group (18-19, 20-29, 30-39, 40-49, 50-59, 60+)

### BMI and Health Indicators
- Average BMI for smokers versus non-smokers
- BMI bucket analysis showing charge averages per BMI category
- Count of policyholders with BMI above 30 (classified as obese)
- Charge comparison: BMI over 30 versus BMI at or below 30

### Family and Dependents
- Average charges among policyholders with children
- Charge totals grouped by number of children
- Smoker distribution by number of children

### Combined Multi-Variable Analysis
- Average charges segmented by smoker status and region
- Average charges segmented by sex and smoking status
- Highest charge recorded for a non-smoker

---

## Key Insights and Findings

### Demographics
- The **average policyholder age is 39 years**
- The gender split is nearly even: **662 female** and **675 male** policyholders
- Regional distribution is balanced, with the **Southeast having the most policyholders (364)**, followed by Southwest (325), Northeast (324), and Northwest (324)
- Average BMI is consistent across genders: **30.38 for females** and **30.94 for males**, both falling in the Obese I classification

### Charges and Cost
- The **average medical charge is $13,279**, with a range of $1,121.87 to $63,770.43
- **Smokers incur nearly 4x higher average charges** ($32,050) compared to non-smokers ($8,441), making smoking the single strongest predictor of high medical costs in this dataset
- The **Southeast region has the highest average charges** at $14,735, while the Southwest has the lowest
- Medical costs **increase steadily with age**, rising from $8,475 for the 18-19 age group to $21,248 for policyholders aged 60 and above

### BMI and Health Risk
- Both smokers and non-smokers have nearly identical average BMIs (30.71 vs. 30.65), suggesting BMI alone does not differentiate smokers from non-smokers in this dataset
- The most common BMI category is **Overweight / Obese I**
- **704 policyholders have a BMI above 30**, representing more than half the dataset
- Policyholders with BMI above 30 incur an average of **$15,581 in charges**, compared to $10,719 for those with BMI at or below 30, a difference of approximately $4,861

### Family and Dependents
- Among policyholders with at least one child, the **average charge is $13,950**
- The **most common number of children is 0**, indicating many policyholders are without dependents
- Smokers tend to have a higher total count of children covered, though this is influenced by the overall composition of the data

### Combined Analysis
- The **Southeast region has the highest average charges for smokers**, making it the highest-risk combination in the dataset
- **Male smokers carry the highest average charges** across all sex-and-smoking combinations
- The highest charge recorded for a **non-smoker is $63,770**, indicating that non-smokers can still generate high claims, likely driven by age, BMI, or chronic conditions

---

## Recommendations

**1. Risk-Based Pricing by Smoking Status and BMI**
Smoking and BMI above 30 are the two strongest cost drivers identified in this analysis. Premium structures should reflect these risk factors more precisely. Policyholders who are both smokers and have BMI above 30 represent the highest-risk segment and should be priced accordingly.

**2. Targeted Wellness Programs**
Design and fund wellness interventions specifically for smokers and individuals with BMI above 30. Smoking cessation programs and weight management incentives can reduce long-term claims costs. Even a modest reduction in the smoker population would yield significant savings given the nearly 4x charge differential.

**3. Southeast Regional Review**
The Southeast consistently appears as the highest-cost region across multiple analyses, including the highest average charges overall and the highest charges for smokers. A focused review of provider pricing, claims patterns, and plan structures in this region is warranted.

**4. Age-Tiered Preventive Care Incentives**
Since charges increase substantially after age 40, insurers should introduce age-tiered incentives for preventive screenings and wellness checkups targeted at policyholders in the 35-49 bracket, before costs escalate significantly.

**5. Scholarship Map for Aligned Extracurricular Recognition**
For policyholders approaching the 60+ tier (average $21,248 in charges), proactive chronic disease management programs and personalized care coordination could reduce avoidable high-cost claims.

---

## Tools Used

| Tool | Purpose |
|---|---|
| **MySQL** | Database engine for all queries and data transformations |
| **MySQL Workbench** | Query development, execution environment, and result visualization |
| **CSV (Excel-compatible)** | Source data format for import |

---

## How to Reproduce

1. Clone or download this repository
2. Open **MySQL Workbench** and connect to your local MySQL instance
3. Create a new schema called `medical`
4. Import `medical_insurance.csv` into a table called `medical_insurance` using the Table Data Import Wizard or a `LOAD DATA` statement
5. Open `SQL Syntax.sql` and run the queries in order from top to bottom
6. Each section is clearly commented with the analytical category and the specific question being answered

> **Note:** The script creates staging tables automatically. You do not need to manually create any tables before running the file.

---

## File Structure

```
medical-insurance-eda/
│
├── medical_insurance.csv       # Raw dataset (1,338 rows, 7 columns)
├── SQL Syntax.sql              # Full SQL script: staging, deduplication, and 20 EDA queries
└── README.md                   # Project documentation (this file)
```

---

## Conclusion

This analysis confirms that **smoking status and BMI are the two most significant drivers of medical insurance charges** in this dataset. The average charge gap between smokers ($32,050) and non-smokers ($8,441) is not marginal. It is a structural cost divide that should inform every layer of policy pricing, risk segmentation, and wellness investment.

Age compounds the picture, with costs nearly tripling from the youngest to oldest age group. The Southeast region warrants closer attention as a consistently high-cost area across multiple dimensions.

Taken together, these findings present a clear case: insurance providers that leverage data to identify, segment, and proactively engage high-risk policyholders will be better positioned to manage costs, improve outcomes, and build a more sustainable book of business.
