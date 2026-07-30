# BL-FNB-SALES

Dashboard link: https://blfnbsalesreport.lovable.app

#Retail Profitability & Pricing Governance (2013–2016)

📌 Project Summary

*Between 2013 and 2016, the BL FNB Sales dataset captured over R161.5 million in retail transactions across major chains and independent wholesale accounts. While trade volumes peaked during 2014–2015, unstructured promotional pricing caused heavy trading below the strategic cost floor of R36.75 COGS.

*This project provides an interactive interface for leadership to audit transaction-level accounts, trace unit economics, and enforce pricing guardrails in real time.

📊 Key Insights & Analytical Findings
*Volume vs. Profitability Paradox (2014–2015): Peak transaction volumes coincided with substantial operating deficits due to promotional discounting below the R36.75 unit cost floor.

*2016 Margin Recovery: Price floor re-anchoring successfully restored gross margins without sacrificing core account retention.

*Automated Risk Flagging: Account-level transactions operating at a negative margin are instantly flagged in red within the live ledger.

🛠️ Project Development Lifecycle
#Phase 1: Data Cleansing & Exploratory Analysis (Excel & SQL)
Dataset Scope: Extracted and processed historical sales records totaling R161.5M in raw revenue.

*Trend Analysis: Evaluated Monthly Gross Profit, Margin Percentage, Elasticity, and Trading Day distributions.

*Baseline Calculation: Established the non-negotiable R36.75 COGS price floor to classify accounts as profitable vs. margin-compliant deficit risks.

#Phase 2: Web Dashboard Architecture & Design (Lovable)

*Design System: Full dark-mode UI engineered with Tailwind CSS, Lucide Icons, and React state controls.

#Interactive Components:

*Reactive KPI Bar: High-level metrics tracking overall revenue, orders, and compliance badges.

*Analytical Charts: Dynamic trendlines visualizing historical recovery (2013–2016).

*Transaction Ledger: Account-level grid equipped with search, category filtering, and status badges.

*Conditional Logic: Built-in UI rules automatically highlight unit prices strictly below R36.75 in prominent red styling.

#Phase 3: Governance Controls & Deployment

*Applied four structural governance pillars:

*POS Hard Locks: Prevent orders below the cost floor from being generated without managerial override.

*Promotion Capping: Strict ceiling on volume-based discount thresholds.

*BI Real-Time Alerts: Immediate notification triggers on deficit transactions.

*Catalog Re-anchoring: Standardized list prices across retail chains and wholesale accounts.

*Deployed directly to production via Lovable Cloud at blfnbsalesreport.lovable.app.

💻 Tech Stack
*Frontend: React, Vite, Tailwind CSS, Lucide React Icons.

*Data Visualization: Recharts, Shadcn UI Components.

*Data Processing & Prep: Microsoft Excel (Pivot tables, formulas, X-axis label optimization) & Python &SQL Databricks.

*Deployment & Hosting: Lovable Platform.
