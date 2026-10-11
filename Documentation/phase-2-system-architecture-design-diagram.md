# Phase 2: System Architecture Diagrams

**Project Name:** Big Brother Student Accommodation Management System  
**Module:** ITC327W Work Integrated Learning  

---

## System Architecture & Data Flow Diagram

```mermaid
graph TD
    classDef user fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef app fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;
    classDef backend fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef note fill:#fafafa,stroke:#616161,stroke-width:1px,stroke-dasharray: 5 5;

    %% Users
    U1[Student<br><i>uses mobile app & web student portal</i>]:::user
    U2[Public Visitor<br><i>prospective tenant</i>]:::user
    U3[Management<br><i>Owner / Property Manager</i>]:::user

    %% Applications
    APP1["Flutter Mobile Application<br>(Student-facing)<br>--<br>• Register, sign in, verify email<br>• Reset password<br>• Upload particulars & documents<br>• View rooms & availability<br>• Apply for accommodation<br>• Book viewings<br>• Track application status<br>• View notifications<br>• Submit reviews/feedback<br>• Profile management"]:::app
    
    APP2["ASP.NET Web Application<br>--<br><b>Public Website:</b><br>• View rooms, availability & info<br><b>Student Portal:</b><br>• Register, sign in, apply & track<br><b>Staff Portal (Management):</b><br>• Dashboard summary<br>• Manage applications & viewings<br>• Manage student records & occupants<br>• Manage rooms & units<br>• Track simulated payment status"]:::app

    %% Backend
    subgraph SB["Shared Supabase Backend"]
        BA[Supabase Auth<br><i>Login, email codes, RBAC</i>]:::backend
        BD[(PostgreSQL Database<br><i>Shared system data</i>)]:::backend
        BS[Supabase Storage<br><i>Student documents & images</i>]:::backend
        BAccess[API / Client Access<br><i>Dart client, C# client, REST</i>]:::backend
        BRealTime[Real-time Subscriptions<br><i>Status updates & notifications</i>]:::backend
        BRLS[Row-Level Security<br><i>Access rules</i>]:::backend
    end

    %% User to App Connections
    U1 --> APP1
    U1 --> APP2
    U2 --> APP2
    U3 --> APP2

    %% App to Backend Connections
    APP1 <==>|Requests / Data<br>Results / Updates| SB
    APP2 <==>|Requests / Data<br>Results / Updates| SB

    %% Note
    N1["The Flutter and ASP.NET applications do not communicate directly. All shared information passes through Supabase.<br>Information updated through one application is available to the other where the approved process requires it."]:::note