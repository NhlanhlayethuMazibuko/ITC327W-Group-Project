# Phase 2: System Architecture Design Explanation

**Project Name:** Big Brother Student Accommodation Management System  
**Module:** ITC327W Work Integrated Learning  

---

## Overview

This document defines the system architecture of the Big Brother Student Accommodation Management System[cite: 8]. It is based on the approved Phase 1 requirements and refined project scope, in which the Flutter mobile application serves students and the ASP.NET web application serves management[cite: 8]. It demonstrates how the Flutter application, the ASP.NET application, and the shared Supabase backend operate as one integrated system[cite: 8].

---

## Users and Roles

| USER / ROLE | USES FLUTTER? | USES ASP.NET? | MAIN PURPOSE |
| :--- | :---: | :---: | :--- |
| **Student** | Yes | No | Create an account and upload particulars, view accommodation and check availability, apply and make bookings, track application status, view, add and change information (subject to management approval), and submit reviews and feedback[cite: 8]. |
| **Management** | No | Yes | Control, monitor and manage data; review and respond to applications and student information; approve student changes; manage accommodation listings, units, occupants, deposits and breakages; track simulated payment status[cite: 8]. |

---

## Components and Responsibilities

| COMPONENT | DESCRIPTION | MAIN RESPONSIBILITIES |
| :--- | :--- | :--- |
| **Flutter Mobile Application** | Mobile application used by students and prospective tenants[cite: 8]. | Account creation and login; upload particulars; view accommodation and availability; apply and make bookings; track application status; view, add and change student information; submit reviews and feedback; view business information[cite: 8]. |
| **ASP.NET Web Application** | Web application used by management[cite: 8]. | Management authentication; review and approve or reject applications; manage student information and approve student changes; manage accommodation listings, units and occupants; track deposits, breakages and simulated payment status; view accommodation viewing summaries[cite: 8]. |
| **Supabase Authentication** | Central authentication service[cite: 8]. | Verifies users and separates student and management access[cite: 8]. |
| **Supabase Database** | Shared PostgreSQL database[cite: 8]. | Stores all system records used by both applications[cite: 8]. |
| **Supabase Storage** | Shared file storage[cite: 8]. | Stores files uploaded by students, such as their particulars and supporting documents[cite: 8]. |
| **Supabase API / Real-time** | Access layer and update notifications[cite: 8]. | Lets both applications read and write shared data and receive updates when data changes[cite: 8]. |
| **Supabase Row-Level Security** | Data access rules[cite: 8]. | Restricts each user to the records they are allowed to access, so students see only their own information[cite: 8]. |

---

## Main Data Flows

| FROM | TO | INFORMATION EXCHANGED | REQUIREMENTS |
| :--- | :--- | :--- | :--- |
| Student via Flutter | Supabase Authentication | Registration and login details[cite: 8]. | FR1, FR10[cite: 8] |
| Supabase Authentication | Flutter / ASP.NET | Verified session and user role (student or management)[cite: 8]. | FR10, NFR5[cite: 8] |
| Student via Flutter | Supabase Storage | Uploaded particulars and supporting documents[cite: 8]. | FR1[cite: 8] |
| Student via Flutter | Supabase Database | Student details, applications, bookings, information changes, reviews and feedback[cite: 8]. | FR1, FR2, FR4, FR14, FR18[cite: 8] |
| Supabase Database | Flutter | Accommodation listings and availability, application status, approved student information and business information[cite: 8]. | FR3, FR4, FR5, FR8, FR9, FR12[cite: 8] |
| Management via ASP.NET | Supabase Authentication | Management login credentials[cite: 8]. | FR10[cite: 8] |
| Supabase Database / Storage | ASP.NET | Applications, student information and documents, bookings, units, occupants, deposits, furniture, breakages and viewing summaries[cite: 8]. | FR6, FR7, FR16, FR17, FR19[cite: 8] |
| ASP.NET | Supabase Database | Application decisions, approval of student changes, unit and occupant updates and simulated payment status[cite: 8]. | FR2, FR6, FR13, FR15, FR19[cite: 8] |
| Supabase Real-time | Flutter / ASP.NET | Notification that shared data has changed[cite: 8]. | FR5, Integration Requirements[cite: 8] |

---

## How the Components Operate as One System

1. **Flutter Users:** Students use the Flutter mobile application[cite: 8].
2. **ASP.NET Users:** Management (owner or property manager) uses the ASP.NET web application[cite: 8].
3. **Supabase:** Shared backend service verifying users, storing all records in one PostgreSQL database, handling file storage, enforcing access rules via Row-Level Security, and broadcasting real-time updates[cite: 8].
4. **Flutter and Supabase Connection:** Flutter connects through the Supabase Dart client[cite: 8].
5. **ASP.NET and Supabase Connection:** ASP.NET connects through the Supabase C# client or REST API using the exact same database tables as Flutter[cite: 8].
6. **One Integrated Solution:** The two frontend applications never communicate directly[cite: 7, 8]. Shared information passes exclusively through Supabase[cite: 7, 8]. For instance, when a student applies in Flutter, the application is stored in Supabase and management sees it in ASP.NET[cite: 8]. When management updates a decision in ASP.NET, Supabase reflects the change and Flutter displays it to the student[cite: 8]. Payments are handled as simulated status data only[cite: 8, 9].