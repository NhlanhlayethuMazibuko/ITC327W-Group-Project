# Phase 1: Feasibility Study

**Project Name:** Big Brother Student Accommodation Management System  
**Module:** ITC327W Work Integrated Learning  

---

## Executive Summary

The proposed student accommodation management system is feasible with minor changes, directly solving the stakeholder’s core operational, marketing, and scam-prevention issues[cite: 9].

---

## Feasibility Area Evaluation

| Feasibility Area | What Must Be Evaluated | Evaluation Summary |
| :--- | :--- | :--- |
| **Technical Feasibility** | Capabilities of the selected technology stack. | **Highly Feasible.** The tech stack (Flutter for mobile frontend, ASP.NET Core for management and public visitors backend APIs, Supabase for cloud database and authentication) directly supports all required capabilities, including a student portal, public view, online room viewing, application submissions, real-time availability tracking, and admin management portals[cite: 9]. |
| **Operational Feasibility** | End-user adoption and operational workflow alignment. | **Highly Feasible.** The application directly addresses critical pain points by modernizing reliance on manual bookings and word-of-mouth marketing[cite: 9]. It eliminates distance barriers by providing remote viewing, mitigates scam risks targeting first years, and streamlines how management tracks and responds to applications[cite: 9]. |
| **Economic Feasibility** | Cost management and budget allocation. | **Feasible with Scope Control.** Developing on an open-source/low-tier backend (Supabase free tier) keeps costs near zero during the academic build phase[cite: 9]. Budgeting focuses solely on developer time and free-tier infrastructure[cite: 9]. |
| **Schedule Feasibility** | Timeline constraints and milestone delivery. | **Feasible with Scope Control.** Building a full end-to-end payment gateway within a single academic semester poses schedule risks[cite: 9]. To ensure delivery, simulated payment status updates are implemented rather than full bank/gateway integration[cite: 9]. |
| **Legal Feasibility** | Data protection and regulatory compliance. | **Feasible.** Handling prospective student personal information (IDs, proof of registration, contact details) requires strict adherence to privacy legislation (e.g., POPIA/GDPR)[cite: 9]. Secure data storage via Supabase with Role-Based Access Control (RBAC) ensures compliant data handling[cite: 9]. |
| **Ethical Feasibility** | Platform fairness and user protection. | **Highly Feasible.** Digitizing the platform protects vulnerable first-year students from accommodation scams and creates a fair, transparent application process for all applicants regardless of their physical location[cite: 9]. |

---

## Overall Feasibility Decision

> **Decision:** **PROCEED WITH SCOPE CONTROL**[cite: 9]  
> **Justification:** The core system solves direct threats to the stakeholder’s business survival[cite: 9]. However, complex live automated payment gateways and complex admin analytics are scaled back to mock features/simulated prototypes to maintain schedule and technical feasibility within the semester timeframe[cite: 9].